module Frank
  module Rescue    
    
    def render_404
      template = File.expand_path(File.dirname(__FILE__)) + '/templates/404.haml'
      locals = { :request => @env, 
                 :dynamic_folder => @dynamic_folder, 
                 :static_folder => @static_folder,
                 :environment => @environment }
                 
      @response['Content-Type'] = 'text/html'
      @response.status          = 404
      obj                       = Object.new.extend(TemplateHelpers)
      @response.body            = Tilt::HamlTemplate.new(template).render(obj, locals = locals)
      
      log_request('404')
    end
  
    def render_500(excp)
      template = File.expand_path(File.dirname(__FILE__)) + '/templates/500.haml'
      locals   = { :request => @env, 
                   :params => @request.params, 
                   :exception => excp }

      @response['Content-Type'] = 'text/html'
      @response.status          = 500
      obj                       = Object.new.extend(TemplateHelpers)
      @response.body            = Tilt::HamlTemplate.new(template).render(obj, locals = locals)  
      
      log_request('500', excp)
    end
    
  end
end
