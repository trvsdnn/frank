require 'frank/tilt'
require 'frank/template_helpers'
require 'frank/rescue'
require 'frank/middleware/statik'
require 'frank/middleware/imager'
require 'frank/middleware/refresh'

module Frank
  VERSION = '0.3.2'
  
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
      load_helpers      
      @response['Content-Type'] = Rack::Mime.mime_type(File.extname(@request.path), 'text/html')
      @response.write render(@request.path)
    rescue Frank::TemplateError
      render_404
    rescue Exception => e
      render_500 e
    end
    
    # prints requests and errors to STDOUT
    def log_request(status, excp=nil)
      out = "\033[1m[#{Time.now.strftime('%Y-%m-%d %H:%M')}]\033[22m (#{@request.request_method}) http://#{@request.host}:#{@request.port}#{@request.fullpath} - #{status}"
      out << "\n\n#{excp.message}\n\n#{excp.backtrace.join("\n")} " if excp
      puts out
    end
    
    def load_helpers
      helpers = File.join(@proj_dir, 'helpers.rb')
      if File.exist? helpers
        load helpers 
        Frank::TemplateHelpers.class_eval("include FrankHelpers")
      end
    end
    
  end
  
  module Render
    
    TMPL_EXTS = { 
      :html => %w[haml erb rhtml builder liquid mustache textile md mkd markdown],
      :css  => %w[sass less scss]
    }
    
    LAYOUT_EXTS = %w[.haml .erb .rhtml .liquid .mustache]
    
    # render request path or template path
    def render(path, partial=false)
      @current_path = path unless partial
      
      # normalize the path
      path.sub!(/^\/?(.*)$/, '/\1')
      path.sub!(/\/$/, '/index.html')
      path.sub!(/(\/[\w-]+)$/, '\1.html')
      path = to_file_path(path) if defined? @request or path.match(/\/_[^\/]+$/)
      
      # regex for kinds that don't support meta
      # and define the meta delimiter
      nometa, delimiter  = /\/_|\.(sass|less)$/, /^META-{3,}\s*$|^-{3,}META\s*$/
      
      # set the layout
      layout = path.match(nometa) ? nil : layout_for(path)
      
      template_path = File.join(@proj_dir, @dynamic_folder, path)
      raise Frank::TemplateError, "Template not found #{template_path}" unless File.exist? template_path
      
      # read in the template
      # check for meta and parse it if it exists
      template        = File.read(template_path) << "\n"
      ext             = File.extname(path)
      template, meta  = template.split(delimiter).reverse
      locals          = parse_meta_and_set_locals(meta)
      
      # use given layout if defined as a meta field
      layout = locals[:layout] == 'nil' ? nil : locals[:layout] if locals.has_key?(:layout)
      
      # let tilt determine the template handler
      # and return some template markup
      if layout.nil?
        tilt(ext, template, locals)
      else
        layout_path = File.join(@proj_dir, @layouts_folder, layout)
        # add layout_path to locals
        raise Frank::TemplateError, "Layout not found #{layout_path}" unless File.exist? layout_path
        
        tilt(File.extname(layout), layout_path, locals) do
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
    def layout_for(path)
      layout_exts = LAYOUT_EXTS.dup
      ext         = File.extname(path)
      default     = 'default' << layout_ext_or_first(layout_exts, ext)
      file_path   = path.sub(/\/[\w-]+\.[\w-]+$/, '')
      folders     = file_path.split('/')
            
      until File.exist? File.join(@proj_dir, @layouts_folder, folders, default)
        break if layout_exts.empty? && folders.empty?
        
        if layout_exts.empty?
          layout_exts = LAYOUT_EXTS.dup
          default = 'default' << layout_ext_or_first(layout_exts, ext)
          folders.pop
        else
          default = 'default' << layout_exts.shift
        end
      end
      
      if File.exists? File.join(@proj_dir, @layouts_folder, folders, default)
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
    # set the current_path local
    def parse_meta_and_set_locals(meta)      
      # parse yaml and symbolize keys
      if meta.nil?
        meta = {}
      else
        meta = YAML.load(meta).inject({}) do |options, (key, value)|
          options[(key.to_sym rescue key) || key] = value
          options
        end
      end  
      meta[:current_path] = @current_path.sub(/\.[\w-]+$/, '').sub(/\/index/, '/')
      
      meta
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
