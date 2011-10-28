require 'frank/tilt_setup'
require 'frank/template_helpers'
require 'frank/rescue'
require 'frank/upgrades'
require 'frank/middleware/statik'

module Frank
  extend Frank::Upgrades

  module Render; end

  class Base
    include Rack::Utils
    include Frank::Rescue
    include Frank::TemplateHelpers
    include Frank::Render

    def call(env)
      dup.call!(env)
    end

    def call!(env)
      @env = env
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      process
      @response.close
      @response.finish
    end

    private

    # attempt to render with the request path,
    # if it cannot be found, render error page
    def process
      load_helpers
      @response['Content-Type'] = Rack::Mime.mime_type(File.extname(@request.path), 'text/html')
      @response.write render(@request.path)
    rescue Frank::TemplateError
      @response.write render_404
    rescue Exception => e
      @response.write render_500(e)
    end

    # prints requests and errors to STDOUT
    def log_request(status, excp = nil)
      out = "\033[1m[#{Time.now.strftime('%Y-%m-%d %H:%M')}]\033[22m (#{@request.request_method}) http://#{@request.host}:#{@request.port}#{@request.fullpath} - #{status}"
      out << "\n\n#{excp.message}\n\n#{excp.backtrace.join("\n")} " if excp
      puts out
    end

    def load_helpers
      helpers = File.join(Frank.root, 'helpers.rb')
      if File.exist? helpers
        load helpers
        Frank::TemplateHelpers.class_eval("include FrankHelpers")
      end
    end
  end

  module Render

    TMPL_EXTS = {
      :html => %w[haml erb rhtml builder liquid textile md mkd markdown],
      :css  => %w[sass less scss],
      :js   => %w[coffee]
    }

    LAYOUT_EXTS = %w[.haml .erb .rhtml .liquid]

    # render request path or template path
    def render(path, partial = false, local_vars = nil)
      @current_path = path unless partial

      # normalize the path
      path.sub!(/^\/?(.*)$/, '/\1')
      path.sub!(/\/$/, '/index.html')
      path.sub!(/(\/[\w-]+)$/, '\1.html')
      path = to_file_path(path) if defined? @request or path.match(/\/_[^\/]+$/)

      # regex for kinds that don't support meta
      # and define the meta delimiter
      nometa, delimiter  = /\/_|\.(scss|sass|less|coffee)$/, /^META-{3,}\s*$|^-{3,}META\s*$/

      # set the layout
      layout = path.match(nometa) ? nil : layout_for(path)

      template_path = File.join(Frank.root, Frank.dynamic_folder, path)
      raise Frank::TemplateError, "Template not found #{template_path}" unless File.exist? template_path

      # read in the template
      # check for meta and parse it if it exists
      template        = File.read(template_path) << "\n"
      ext             = File.extname(path)
      template, meta  = template.split(delimiter).reverse
      locals          = parse_meta_and_set_locals(meta, local_vars)

      # use given layout if defined as a meta field
      layout = locals[:layout] == 'nil' ? nil : locals[:layout] if locals.has_key?(:layout)

      page = setup_page

      # let tilt determine the template handler
      # and return some template markup
      if layout.nil?
        tilt(page, ext, template, template_path, locals)
      else
        layout_path = File.join(Frank.root, Frank.layouts_folder, layout)
        # add layout_path to locals
        raise Frank::TemplateError, "Layout not found #{layout_path}" unless File.exist? layout_path

        page_content = tilt(page, ext, template, template_path, locals)
        tilt(page, File.extname(layout), nil, layout_path, locals) do
          page_content
        end
      end
    end

    # converts a request path to a template path
    def to_file_path(path)
      file_name = File.basename(path, File.extname(path))
      file_ext  = File.extname(path).sub(/^\./, '')
      folder    = File.join(Frank.root, Frank.dynamic_folder)
      engine    = nil

      TMPL_EXTS.each do |ext, engines|
        if ext.to_s == file_ext
          engine = engines.reject do |eng|
            !File.exist? File.join(folder, path.sub(/\.[\w-]+$/, ".#{eng}"))
          end.first
        end
      end

      raise Frank::TemplateError, "Template not found #{path}" if engine.nil?

      path.sub(/\.[\w-]+$/, ".#{engine}")
    end

    # lookup the original ext for given template path
    def ext_from_handler(extension)
      ext = extension[1..-1]
      TMPL_EXTS.each do |orig_ext, engines|
        return orig_ext.to_s if engines.include? ext
      end
    end

    # reverse walks the layouts folder until we find a layout
    # returns nil if layout is not found
    def layout_for(path)
      layout_exts = LAYOUT_EXTS.dup
      ext         = File.extname(path)
      default     = 'default' << layout_ext_or_first(layout_exts, ext)
      file_path   = path.sub(/\/[\w-]+\.[\w-]+$/, '')
      folders     = file_path.split('/')

      until File.exist? File.join(Frank.root, Frank.layouts_folder, folders, default)
        break if layout_exts.empty? && folders.empty?

        if layout_exts.empty?
          layout_exts = LAYOUT_EXTS.dup
          default = 'default' << layout_ext_or_first(layout_exts, ext)
          folders.pop
        else
          default = 'default' << layout_exts.shift
        end
      end

      if File.exists? File.join(Frank.root, Frank.layouts_folder, folders, default)
        File.join(folders, default)
      else
        nil
      end
    end

    # if the given ext is a layout ext, pop it off and return it
    # otherwise return the first layout ext
    def layout_ext_or_first(layout_exts, ext)
      layout_exts.include?(ext) ? layout_exts.delete(ext) : layout_exts.first
    end

    # render a page using tilt and get the result template markup back
    def tilt(page, ext, source, filename, locals={}, &block)
      Tilt[ext].new(filename) do
        source || File.read(filename)
      end.render(page, locals=locals, &block)
    end

    # setup a new page object to be rendered
    def setup_page
      page = Object.new.extend(TemplateHelpers).extend(Render)
      instance_variables.each do |var|
        unless ['@response', '@env'].include? var
          page.instance_variable_set(var.intern, instance_variable_get(var))
        end
      end
      page
    end

    private

    # parse the given meta string with yaml
    # set the current_path local
    def parse_meta_and_set_locals(meta, locals = nil)
      # parse yaml and symbolize keys
      if meta.nil?
        meta = {}
      else
        meta = YAML.load(meta).inject({}) do |options, (key, value)|
          options[(key.to_sym rescue key) || key] = value
          options
        end
      end
      meta.merge!(locals) unless locals.nil?
      meta[:current_path] = @current_path.sub(/\.[\w-]+$/, '').sub(/\/index/, '/')

      meta
    end
  end

  # Bootstrap will set up Frank up at a root path, and read in the setup.rb
  def self.bootstrap(new_root = nil)
    Frank.reset
    Frank.root = new_root if new_root

    if %w[publish p].include? ARGV.first
      begin
        require 'net/ssh'
        require 'net/scp'
      rescue LoadError
        puts "\033[31mpublish requires the 'net-scp' gem. `gem install net-scp'\033[0m"
        exit!
      end
    end

    # setup compass
    begin
      require 'compass'

      Compass.configuration do |config|
        # project_path should be the directory to which the sass directory is relative.
        # I think maybe this should be one more directory up from the configuration file.
        # Please update this if it is or remove this message if it can stay the way it is.
        config.project_path = Frank.root
        config.sass_dir = File.join('dynamic', 'stylesheets')
      end

      # sass_engine_options returns a hash, you can merge it with other options.
      Frank.sass_options = Compass.sass_engine_options
    rescue LoadError
      # ignore if compass is not there
    end

    # try to pull in setup
    setup = File.join(Frank.root, 'setup.rb')

    if File.exists?(setup)
      load setup
    elsif File.exist? File.join(Dir.pwd, 'settings.yml')
      puts "\033[31mFrank could not find setup.rb, perhaps you need to upgrade with the `frank upgrade\' command \033[0m"
      exit!
    end

  end

  # starts the server
  def self.new(&block)
    base = Base.new(&block)

    builder = Rack::Builder.new do
      use Frank::Middleware::Statik, :root => Frank.static_folder
      run base
    end

    unless Frank.environment == :test
      message = ['got it under control', 'got your back', 'holdin\' it down', 'takin\' care of business', 'workin\' some magic'].sort_by{rand}.first.strip

      puts "\n-----------------------"
      if Frank.serving_static?
        puts " This doesn't look like a frank project. Frank's serving this folder up his way..."
      else
        puts " Frank's #{ message }..."
      end
      puts " #{Frank.server.hostname}:#{Frank.server.port} \n\n"

      Rack::Handler.get('thin').run(builder, :Port => Frank.server.port, :Host => Frank.server.hostname) do
        trap(:INT) { puts "\n\n-----------------------\n Show's over, fellas.\n\n"; exit }
      end
    end

    base

    rescue Errno::EADDRINUSE
      puts " Hold on a second... Frank works alone.\n \033[31mSomething's already using port #{Frank.server.port}\033[0m\n\n"
  end

  # copies over the generic project template
  def self.stub(project)
    templates_dir = File.join(ENV['HOME'], '.frank_templates')
    choice = nil

    puts "\nFrank is...\n - \033[32mCreating\033[0m your project '#{project}'"

    # if user has a ~/.frank_templates folder
    # provide an interface for choosing template
    if File.exist? templates_dir
      templates = %w[default] + Dir[File.join(templates_dir, '**')].map { |d| d.split('/').last }

      puts "\nWhich template would you like to use? "
      templates.each_with_index { |t, i| puts " #{i + 1}. #{t}" }

      print '> '

      # get input and wait for a valid response
      trap(:INT) { puts "\nbye"; exit }
      choice = STDIN.gets.chomp
      until ( choice.match(/^\d+$/) && templates[choice.to_i - 1] ) || choice == '1'
        print " `#{choice}' \033[31mis not a valid template choice\033[0m\n> "
        choice = STDIN.gets.chomp
      end
    end

    Dir.mkdir project
    template = choice.nil? ? 'default' : templates[choice.to_i - 1]

    puts " - \033[32mCopying\033[0m #{template} Frank template"

    if template == 'default'
      FileUtils.cp_r( Dir.glob(File.join(LIBDIR, 'template/*')), project )
    else
      FileUtils.cp_r( Dir.glob(File.join(templates_dir, "#{template}/*")), project )
    end

    puts "\n \033[32mCongratulations, '#{project}' is ready to go!\033[0m"
  rescue Errno::EEXIST
    puts "\n \033[31muh oh, directory '#{project}' already exists...\033[0m"
    exit
  end

end
