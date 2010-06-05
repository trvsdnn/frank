module Frank
  module Middleware
    class Refresh
 
      def initialize(app, options={})
        @app = app
      end
    
      # catch __refrank__ path and
      # return timestamps for given file paths
      def call(env)
        request = Rack::Request.new(env)
       
        if request.path_info.include? '__refresh__'
          [ 200, { 'Content-Type' => 'application/json' }, get_mtimes(request.params) ]
        else
          @app.call(env)
        end
      
      end
    
      private
    
      def get_mtimes(params)
        template_mtime  = File.new(params['template_path']).mtime.to_i
        layout_mtime    = File.new(params['layout_path']).mtime.to_i
        "[ #{template_mtime}, #{layout_mtime} ]"
      end
    end
  end
end