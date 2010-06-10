module Frank
  module Middleware
    class Refresh
 
      def initialize(app, options={})
        @app     = app
        @folders = options[:watch]
      end
    
      # catch __refrank__ path and
      # return the most recent timestamp
      def call(env)
        request = Rack::Request.new(env)
        if request.path_info.match /^\/__refresh__$/
          [ 200, { 'Content-Type' => 'application/json' }, "[#{get_mtime}]" ]
        else
          @app.call(env)
        end
      
      end
    
      private
    
      def get_mtime
        timestamps = []
        @folders.each do |folder|
          Dir[File.join(Dir.pwd, folder, '**/*.*')].each do |found|
            timestamps << File.mtime(found).to_i unless File.directory?(found)
          end
        end
        timestamps.sort.last
      end
      
    end
  end
end
