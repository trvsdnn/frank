module Frank
  begin
    require 'mini_magick'
  rescue LoadError
  end

  class Imager
  
    def initialize(app, options={})
      @app = app
    end
  
    # choose a random image if random is in the query
    def image_filename(dims, query)      
      if query == 'random'
        "frank#{rand(10)}.jpg"
      else
        "frank#{dims.hash.to_s[-1..-1]}.jpg"
      end  
    end
  
    # catch a request for _img/0x0, get an image, resize it to given dims
    def call(env)
      path = env['PATH_INFO']
      image_path = File.expand_path(File.dirname(__FILE__)) + '/templates/imager/'

      if defined?(MiniMagick) && path.include?('_img')
        dims = '!' + path.split('/').last.match(/\d+x\d+/i).to_s
        filename = image_filename(dims, env['QUERY_STRING'])
      
        image = MiniMagick::Image.from_file(image_path + filename)
        image.resize dims
        return [ 200, { 'Content-Type' => 'image/jpg' }, image.to_blob ] 
      end
      @app.call(env)
    end
 
  end
end