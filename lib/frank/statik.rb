class Rack::Statik
 
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
    path = env['PATH_INFO']
 
    if path.include? '__frank__'
      env['PATH_INFO'].gsub!('/__frank__', '')
      result = @frank_server.call(env)
    elsif path.index('/') == 0
      result = @static_server.call(env)
    end
    return result if result[0] == 200
    @app.call(env)
  end
 
end