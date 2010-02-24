require 'frank/lorem'
require 'frank/imager'

module Frank
  module TemplateHelpers
    include FrankHelpers
    include Imager::Helpers
  
    def render_partial(path)
      pieces = path.split('/')
      partial = '_' + pieces.pop
      render_path File.join(pieces.join('/'), partial)
    end
    
    def lorem
      Lorem
    end
    
  end
end