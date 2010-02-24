require 'mini_magick'
module Imager 
  class Rack::Imager
 
    def initialize(app, options={})
      @app = app
    end
  
    def image_filename(dims, query)      
      if query == 'random'
        "frank#{rand(10)}.jpg"
      else
        "frank#{dims.hash.to_s[-1..-1]}.jpg"
      end  
    end
 
    def call(env)
      path = env['PATH_INFO']
      image_path = File.expand_path(File.dirname(__FILE__)) + '/templates/imager/'
 
      if path.include? '_img'
        
        dims = '!' + path.split('/').last.match(/\d+x\d+/i).to_s
        filename = image_filename(dims, env['QUERY_STRING'])
        
        image = MiniMagick::Image.from_file(image_path + filename)
        image.resize dims
        return [ 200, { 'Content-Type' => 'image/jpg' }, image.to_blob ] 
      end
      @app.call(env)
    end
 
  end
  
  module Helpers
    def imager(width, height, random=false)
      "_img/#{width.to_s}x#{height.to_s}.jpg#{'?random' if random}"
    end
  end

end