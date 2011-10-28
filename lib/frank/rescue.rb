module Frank
  module Rescue

    def render_404
      log_request('404')
      template = File.expand_path(File.dirname(__FILE__)) + '/templates/404.haml'
      locals = { :request => @env,
                 :site_folder => Frank.site_folder,
                 :environment => Frank.environment }

      @response['Content-Type'] = 'text/html'
      @response.status          = 404

      obj = Object.new.extend(TemplateHelpers)
      Tilt::HamlTemplate.new(template).render(obj, locals = locals)
    end

    def render_500(excp)
      log_request('500', excp)
      template = File.expand_path(File.dirname(__FILE__)) + '/templates/500.haml'
      locals   = { :request => @env,
                   :params => @request.params,
                   :exception => excp }

      @response['Content-Type'] = 'text/html'
      @response.status          = 500

      obj = Object.new.extend(TemplateHelpers)
      Tilt::HamlTemplate.new(template).render(obj, locals = locals)
    end

  end
end
