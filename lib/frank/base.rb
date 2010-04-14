require 'frank/tilt'
require 'frank/template_helpers'
require 'frank/rescue'
require 'frank/statik'
require 'frank/imager'

module Frank
  VERSION = '0.2.6'
  
  module Render; end
  
  class Base
    include Rack::Utils
    include Frank::Rescue
    include Frank::TemplateHelpers
    include Frank::Render
    
    attr_accessor  :environment, :proj_dir, :server, :static_folder, :dynamic_folder, :templates
    
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
      ext = File.extname(@request.path.split('/').last || '')
      @response['Content-Type'] = Rack::Mime.mime_type(ext, 'text/html')
      @response.write render_path(@request.path)
    rescue Frank::TemplateError
      render_404
    rescue Exception => e
      render_500 e
    end
    
    # prints requests and errors to STDOUT
    def log_request(status, excp=nil)
      out = "[#{Time.now.strftime('%Y-%m-%d %H:%M')}] (#{@request.request_method}) http://#{@request.host}:#{@request.port}#{@request.fullpath} - #{status}"
      out += "\n\n**QUACK** #{excp.message}\n\n#{excp.backtrace.join("\n")} " if excp
      STDOUT.puts out unless @environment == :test
    end
    
  end
  
  module Render
    
    def name_ext(path)
      return path.split(/\.(?=[^.]+$)/)
    end
    
    # breaks down path and renders partials, js, css without layouts
    def render_path(path)
      path.sub!(/^\//,'')
      template, ext = find_template_ext(path)
      
      raise Frank::TemplateError, "Template not found #{path}" if template.nil?
      if template.match(/^_/) or (ext||'').match(/^(js|css)$/)
        render_template template
      else
        render_with_layout template
      end
    end
    
    # renders a template
    def render_template(tmpl, *args)
      tilt(File.join(@proj_dir, @dynamic_folder, tmpl), *args) {"CONTENT"}
    end
    
    # if template has a layout defined, render template within layout
    # otherwise render template
    def render_with_layout(tmpl, *args)
      if layout = get_layout_for(tmpl)
        tilt(File.join(@proj_dir, @dynamic_folder, layout), *args) do
          render_template tmpl
        end
      else
        render_template tmpl
      end
    end
    
    TMPL_EXTS = { :html => %w[haml erb rhtml builder liquid mustache textile md mkd markdown],
                  :css => %w[sass less],
                  :js => %w[coffee] }
                  
    def reverse_ext_lookup(ext)
      TMPL_EXTS.each do |kind, exts|
        return kind.to_s if exts.index(ext)
      end
      nil
    end
    
    # finds template extension based on filename
    # TODO: cleanup
    def find_template_ext(filename)
      name, kind = name_ext(filename)      
      kind = reverse_ext_lookup(kind) if kind && TMPL_EXTS[kind.intern].nil?      
      
      tmpl_ext = nil
      
      TMPL_EXTS[ kind.nil? ? :html : kind.intern ].each do |ext|
        tmpl = "#{(name||'')}.#{ext}"
        default = File.join((name||''), "index.#{ext}")
        
        if File.exists? File.join(@proj_dir, @dynamic_folder, tmpl)
          tmpl_ext = [tmpl, ext] 
        elsif File.exists? File.join(@proj_dir, @dynamic_folder, default)
          tmpl_ext = [default, ext]
        end
      end
      
      tmpl_ext
    end
    
    # determines layout using layouts settings
    # TODO: cleanup
    def get_layout_for(view)
      view, ext = name_ext(view)
      
      layouts = @templates['layouts'] || []
      onlies = layouts.select {|l| l['only'] }
      nots = layouts.select {|l| l['not'] }
      blanks = layouts - onlies - nots
            
      layout = onlies.select {|l| l['only'].index(view) }.first 
      layout = nots.reject {|l| l['not'].index(view) }.first unless layout
      layout = blanks.first unless layout
      
      # TODO: we are checking for exts in two places, consolidate soon
      layout = nil if !blanks.empty? && blanks.first['name'] == view
      layout = nil if (TMPL_EXTS[:css] + TMPL_EXTS[:js]).include?(ext)
            
      layout.nil? ? nil : layout['name'] + '.' + ext
    end
    
    # TODO: cleanup
    def tilt(file, *args, &block)      
      locals = @request.nil? ? {} : { :request => @env, :params => @request.params }
      obj = Object.new.extend(TemplateHelpers).extend(Render)
      obj.instance_variable_set(:@proj_dir, @proj_dir)
      obj.instance_variable_set(:@dynamic_folder, @dynamic_folder)
      obj.instance_variable_set(:@templates, @templates)
      Tilt.new(file, 1).render(obj, locals, &block)
    end
  
    def remove_ext(path)
      path.gsub(File.extname(path), '')
    end
    
  end
  
  # starts the server
  def self.new(&block)
    base = Base.new(&block) if block_given?
    
    builder = Rack::Builder.new do
      use Frank::Statik, :root => base.static_folder
      use Frank::Imager
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
    puts "\nFrank is..."
    puts " - \033[32mCreating\033[0m your project '#{project}'"
    Dir.mkdir project
    puts " - \033[32mCopying\033[0m Frank template"
    FileUtils.cp_r( Dir.glob(File.join(LIBDIR, 'template/*')), project )
    puts "\n \033[32mCongratulations, '#{project}' is ready to go!\033[0m"
  rescue Errno::EEXIST
    puts "\n \033[31muh oh, directory '#{project}' already exists...\033[0m"
    exit
  end
  
end
