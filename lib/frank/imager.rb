require 'mini_magick'
module Imager 
  class Rack::Imager
 
    def initialize(app, options={})
      @app = app
    end
  
    def image_filename(dims)
      "frank#{dims.hash.to_s[-1..-1]}.jpg"
    end
 
    def call(env)
      path = env['PATH_INFO']
      image_path = File.expand_path(File.dirname(__FILE__)) + '/templates/imager/'
 
      if path.include? '_img'
        dims = '!' + env['PATH_INFO'].split('/').last.match(/\d+x\d+/i).to_s
        filename = image_filename(dims)
        image = MiniMagick::Image.from_file(image_path + filename)
        image.resize dims
        return [ 200, { 'Content-Type' => 'image/jpg' }, image.to_blob ] 
      end
      @app.call(env)
    end
 
  end
  
  module Helpers
    def imager(width, height, random=false)
      "_img/#{width.to_s}x#{height.to_s}.jpg"
    end
  end

end