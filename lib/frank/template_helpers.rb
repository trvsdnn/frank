require 'frank/lorem'

module Frank
  module TemplateHelpers
    include FrankHelpers if defined? FrankHelpers
  
    def render_partial(path)
      pieces = path.split('/')
      partial = '_' + pieces.pop
      render(File.join(pieces.join('/'), partial))
    end
    
    def lorem
      Frank::Lorem.new(@environment)
    end
    
    def selected_if(path)
      current_path.scan(path).empty? ? '' : 'selected'
    end
    
  end
end