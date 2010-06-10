require 'frank/tilt'
require 'frank/template_helpers'
require 'frank/rescue'
require 'frank/middleware/statik'
require 'frank/middleware/imager'
require 'frank/middleware/refresh'

module Frank
  VERSION = '0.3.0'
  
  module Render; end
  
  class Base
    include Rack::Utils
    include Frank::Rescue
    include Frank::TemplateHelpers
    include Frank::Render
    
    attr_accessor :environment
    attr_accessor :proj_dir
    attr_accessor :server
    attr_accessor :static_folder
    attr_accessor :dynamic_folder
    attr_accessor :layouts_folder
    attr_accessor :templates
    
    def initialize(&block)
      instance_eval &block
    end

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
    
    # setter for options
    def set(option, value)  
      if respond_to?("#{option}=")
        send "#{option}=", value
      end
    end
    
    # attempt to render with the request path,
    # if it cannot be found, render error page
    def process      
      @response['Content-Type'] = Rack::Mime.mime_type(File.extname(@request.path), 'text/html')
      @response.write render(@request.path)
    rescue Frank::TemplateError
      render_404
    rescue Exception => e
      render_500 e
    end
    
    # prints requests and errors to STDOUT
    def log_request(status, excp=nil)
      out = "[#{Time.now.strftime('%Y-%m-%d %H:%M')}] (#{@request.request_method}) http://#{@request.host}:#{@request.port}#{@request.fullpath} - #{status}"
      out << "\n\n#{excp.message}\n\n#{excp.backtrace.join("\n")} " if excp
      puts out
    end
    
  end
  
  module Render
    
    TMPL_EXTS = { 
      :html => %w[haml erb rhtml builder liquid mustache textile md mkd markdown],
      :css  => %w[sass less],
      :js   => %w[coffee]
    }         
    
    # render request path or template path
    def render(path)
      # normalize the path
      path.sub!(/^\/?(.*)$/, '/\1')
      path.sub!(/\/$/, '/index.html')
      path.sub!(/(\/[\w-]+)$/, '\1.html')
      path = to_file_path(path) if defined? @request
      # puts path
      # regex for kinds that don't support meta
      # and define the meta delimiter
      nometa, delimiter  = /\/_|\.(js|coffee|css|sass|less)$/, /^META-{3,}\n$/
      
      # set the layout
      layout = path.match(nometa) ? nil : layout_for(path)
      
      @template_path = File.join(@proj_dir, @dynamic_folder, path)
      raise Frank::TemplateError, "Template not found #{@template_path}" unless File.exist? @template_path
      
      # read in the template
      # check for meta and parse it if it exists
      template        = File.read(@template_path)
      ext             = File.extname(path)
      template, meta  = template.split(delimiter).reverse if template.scan(delimiter)
      locals          = parse_meta_and_set_locals(meta, path)
      
      # use given layout if defined as a meta field
      layout = locals[:layout] == 'nil' ? nil : locals[:layout] if locals.has_key?(:layout)
      
      # let tilt determine the template handler
      # and return some template markup
      if layout.nil?
        tilt(ext, template, locals)
      else
        @layout_path = File.join(@proj_dir, @layouts_folder, layout)
        # add layout_path to locals
        # locals[:layout_path] = layout_path
        raise Frank::TemplateError, "Layout not found #{@layout_path}" unless File.exist? @layout_path
        
        tilt(File.extname(layout), @layout_path, locals) do
          tilt(ext, template, locals)
        end          
      end
    end
    
    # converts a request path to a template path
    def to_file_path(path)
      file_name = File.basename(path, File.extname(path))
      file_ext  = File.extname(path).sub(/^\./, '')
      folder    = File.join(@proj_dir, @dynamic_folder)
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
    # TODO: make non-ugly
    def ext_from_handler(extension)
      orig_ext = nil
      TMPL_EXTS.each do |ext, engines|
        orig_ext = ext.to_s if engines.include? extension[1..-1]
      end
      orig_ext
    end
    
    # reverse walks the layouts folder until we find a layout
    # returns nil if layout is not found
    # TODO: rewrite this... it was late
    # def layout_for(path)
    #   layout  = nil
    #   default = "default#{File.extname(path)}"
    #   folders = path.split('/').reject { |f| f.match /^$|\.[\w-]+/ }
    #   
    #   (1..folders.length).to_a.reverse.each do |i|
    #     this_path = folders[0..i].join('/')
    #     puts this_path
    #     if File.exist? File.join(@proj_dir, @layouts_folder, this_path, default)
    #       layout ||= File.join this_path, default 
    #     end
    #   end
    #   
    #   layout = default if layout.nil? and File.exist? File.join(@proj_dir, @layouts_folder, default)
    # 
    #   layout
    # end
    
    # reverse walks the layouts folder until we find a layout
    # returns nil if layout is not found
    def layout_for(path)
      default = "default#{File.extname(path)}"
      path = path.sub /\/[\w-]+\.[\w-]+$/, ''
      folders = path.split('/')
      
      until File.exist? File.join(@proj_dir, @layouts_folder, folders, default)
        break if folders.empty?
        folders.pop
      end

      if File.exist? File.join(@proj_dir, @layouts_folder, folders, default)
        File.join(folders, default)
      else
        nil
      end
    end
          
    # setup an object and extend it with TemplateHelpers and Render
    # then send everything to tilt and get some template markup back
    def tilt(ext, source, locals={}, &block)
      obj = Object.new.extend(TemplateHelpers).extend(Render)
      instance_variables.each do |var|
        unless ['@response', '@env'].include? var
          obj.instance_variable_set(var.intern, instance_variable_get(var))
        end
      end
      Tilt[ext].new(source).render(obj, locals=locals, &block)
    end
    
    private
    
    # parse the given meta string with yaml
    # add current path
    # and add instance variables
    def parse_meta_and_set_locals(meta, path)
      locals = {}
      
      # parse yaml and symbolize keys
      if meta.nil?
        meta = {}
      else
        meta = YAML.load(meta).inject({}) do |options, (key, value)|
          options[(key.to_sym rescue key) || key] = value
          options
        end
      end
      
      # normalize current_path
      # and add it to locals
      current_path = path.sub(/\.[\w-]+$/, '').sub(/\/index/, '/')
      locals[:current_path] = current_path
      
      meta.merge(locals)
    end
    
  end
  
  # starts the server
  def self.new(&block)
    base = Base.new(&block) if block_given?
    
    builder = Rack::Builder.new do
      use Frank::Middleware::Statik, :root => base.static_folder
      use Frank::Middleware::Imager
      use Frank::Middleware::Refresh, :watch => [ base.dynamic_folder, base.static_folder, base.layouts_folder ]
      run base
    end

    unless base.environment == :test
      m = "got it under control \n got your back \n holdin' it down
             takin' care of business \n workin' some magic".split("\n").sort_by{rand}.first.strip
      puts "\n-----------------------\n" +
           " Frank's #{ m }...\n" +
           " #{base.server['hostname']}:#{base.server['port']} \n\n"
      server = Rack::Handler.get(base.server['handler'])
      
      server.run(builder, :Port => base.server['port'], :Host => base.server['hostname']) do
        trap(:INT) { puts "\n\n-----------------------\n Show's over, fellas.\n\n"; exit }
      end
    end
    
    base
    
    rescue Errno::EADDRINUSE
      puts " Hold on a second... Frank works alone.\n \033[31mSomething's already using port #{base.server['port']}\033[0m\n\n"
  end
  
  # copies over the generic project template
  def self.stub(project)
    puts "\nFrank is...\n - \033[32mCreating\033[0m your project '#{project}'"
    Dir.mkdir project
    puts " - \033[32mCopying\033[0m Frank template"
    FileUtils.cp_r( Dir.glob(File.join(LIBDIR, 'template/*')), project )
    puts "\n \033[32mCongratulations, '#{project}' is ready to go!\033[0m"
  rescue Errno::EEXIST
    puts "\n \033[31muh oh, directory '#{project}' already exists...\033[0m"
    exit
  end
  
end
