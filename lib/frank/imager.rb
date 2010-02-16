require 'mini_magick'

class Rack::Imager
 
  def initialize(app, options={})
    @app = app
  end
 
  def call(env)
    path = env['PATH_INFO']
    image_path = File.expand_path(File.dirname(__FILE__)) + '/templates/imager/'
 
    if path.include? '_img'
      dims = '!' + env['PATH_INFO'].split('/').last.match(/\d+x\d+/i).to_s
      filename = "frank#{rand(8)+1}.jpg"
      image = MiniMagick::Image.from_file(image_path + filename)
      image.resize dims
      return [ 200, { 'Content-Type' => 'image/png' }, image.to_blob ] 
    end
    @app.call(env)
  end
 
end