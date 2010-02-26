module Frank
  module Rescue
    
    def render_404
      template = File.expand_path(File.dirname(__FILE__)) + '/templates/404.haml'
      locals = { :request => @env, :dynamic_folder => @dynamic_folder }

      @response['Content-Type'] = 'text/html'
      @response.status = 404
      @response.body = Tilt.new(template, 1).render(Object.new, locals = locals)
      log_request('404')
    end
  
    def render_500(excp)
      template = File.expand_path(File.dirname(__FILE__)) + '/templates/500.haml'
      locals = { :request => @env, :params => @request.params, :exception => excp }

      @response['Content-Type'] = 'text/html'
      @response.status = 500
      @response.body = Tilt.new(template, 1).render(Object.new, locals = locals)   
      log_request('500', excp)
    end
  end
end