require 'rack'
require 'frank/tilt'
require 'frank/template_helpers'
require 'frank/rescue'
require 'frank/statik'


module Frank
  
  module Render; end
    
  class Base
    include Rack::Utils
    include Frank::Rescue
    include Frank::TemplateHelpers
    include Frank::Render
    
    attr_accessor  :env, :server, :static_folder, :dynamic_folder, :templates
    
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
      begin
        ext = File.extname(@request.path.split('/').last || '')
        @response['Content-Type'] = Rack::Mime.mime_type(ext, 'text/html')
        @response.write render_path(@request.path)
      rescue Errno::ENOENT
        render_404
      rescue Exception => e
        render_500 e
      end
    end
    
    # prints requests and errors to STDOUT
    def log_request(status, excp=nil)
      out = "[#{Time.now.strftime('%Y-%m-%d %H:%M')}] (#{@server['handler'].capitalize}) http://#{@request.host}:#{@request.port}#{@request.fullpath} [#{@request.request_method}] - #{status}"
      out += "\n\n**QUACK** #{excp.message}\n\n#{excp.backtrace.join("\n")} " if excp
      STDOUT.puts out
    end
    
  end
  
  module Render
    
    def name_ext(path)
      return path.split(/\.(?=[^.]+$)/)
    end
    
    def render_path(path)
      path.sub!(/^\//,'')
      template, ext = find_template_ext(path)
      raise Errno::ENOENT if template.nil?
      
      if template.match(/^_/) or (ext||'').match(/^(js|css)$/)
        render_template template
      else
        render_with_layout template
      end
    end

    def render_template(tmpl, *args)      
      tilt_with_request(File.join(@dynamic_folder, tmpl), *args) {"CONTENT"}
    end

    def render_with_layout(tmpl, *args)      
      if layout = get_layout_for(tmpl)
        tilt_with_request(File.join(@dynamic_folder, layout), *args) do
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

    def find_template_ext(filename)
      name, kind = name_ext(filename)
      kind = reverse_ext_lookup(kind) if kind && TMPL_EXTS[kind.intern].nil?

      TMPL_EXTS[ kind.nil? ? :html : kind.intern ].each do |ext|
        tmpl = "#{(name||'')}.#{ext}"        
        return [tmpl, kind] if File.exists? File.join(@dynamic_folder, tmpl)
      end
      
      TMPL_EXTS[ kind.nil? ? :html : kind.intern ].each do |ext|
        default = File.join((name||''), "#{@templates['default']}.#{ext}")
        return [default, kind] if File.exists? File.join(@dynamic_folder, default)
      end
      nil
    rescue
      nil
    end
    
    def get_layout_for(view)
      view, ext = name_ext(view)
      layouts = @templates['layouts'] || []
    
      onlies = layouts.select {|l| l['only'] }
      nots = layouts.select {|l| l['not'] }
      blanks = layouts - onlies - nots
    
      layout = onlies.select {|l| l['only'].index(view) }.first
      layout = nots.reject {|l| l['not'].index(view) }.first unless layout
      layout = blanks.first unless layout
    
      layout.nil? ? nil : layout['name'] + '.' + ext
    end
    
    def tilt_lang(file, lang, *tilt_args, &block)
      Tilt[lang].new(file, 1).render(*tilt_args, &block)
    end
    
    def tilt_with_request(file, *args, &block)      
      locals = @request.nil? ? {} : { :request => @env, :params => @request.params }
      obj = Object.new.extend(TemplateHelpers).extend(Render)
      obj.instance_variable_set(:@dynamic_folder, @dynamic_folder)
      obj.instance_variable_set(:@templates, @templates)
      Tilt.new(file, 1).render(obj, locals, &block)
    end
  
    def remove_ext(path)
      path.gsub(File.extname(path), '')
    end
    
  end
  
  def self.new(&block)
    base = Base.new(&block) if block_given?
    
    builder = Rack::Builder.new do
      use Rack::Statik, :root => base.static_folder
      run base
    end

    unless base.env == 'test'
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
  
end
