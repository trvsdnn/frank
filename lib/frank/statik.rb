module Frank
  class Statik
 
    def initialize(app, options={})
      @app = app
      frank_root = File.expand_path(File.dirname(__FILE__)) + '/templates'
      root = options[:root] || Dir.pwd
      @frank_server = Rack::File.new(frank_root)
      @static_server = Rack::File.new(root)
    end
 
    # handles serving from __frank__
    # looks for static access, if not found,
    # passes request to frank
    def call(env)
      path = env['PATH_INFO'].dup
 
      if path.include? '__frank__'
        env['PATH_INFO'].gsub!('/__frank__', '')
        result = @frank_server.call(env)
      else
        env['PATH_INFO'] << '/' unless path.match(/(\.\w+|\/)$/)
        env['PATH_INFO'] << 'index.html' if path[-1..-1] == '/'
        result = @static_server.call(env)
      end
      
      # return if static assets found
      # else reset the path and pass to frank
      if result[0] == 200
        result
      else
        env['PATH_INFO'] = path
        @app.call(env)
      end
      
    end
 
  end
end