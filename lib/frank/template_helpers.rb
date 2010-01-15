module Frank
  module TemplateHelpers
    include FrankHelpers
  
    def render_partial(path)
      pieces = path.split("/")
      partial = '_' + pieces.pop
      render_path File.join(pieces.join('/'), partial)
    end
    
  end
end