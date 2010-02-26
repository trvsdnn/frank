require 'frank/lorem'

module Frank
  module TemplateHelpers
    include FrankHelpers if defined? FrankHelpers
  
    def render_partial(path)
      pieces = path.split('/')
      partial = '_' + pieces.pop
      render_path File.join(pieces.join('/'), partial)
    end
    
    def lorem
      Frank::Lorem
    end
    
  end
end