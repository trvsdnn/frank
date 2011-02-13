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
          [ 200, { 'Content-Type' => 'application/json', 'Connection' => 'Keep-Alive', 'Keep-Alive' => 'timeout=60', 'Cache-Control' => 'max-age=0' }, "#{get_mtime}" ]
        else
          @app.call(env)
        end
      end

      private

      # build list of mtimes for watched files
      # return the most recent
      def get_mtime
        pwd        = Dir.pwd
        timestamps = []
        helpers    = File.join(pwd, 'helpers.rb')

        timestamps << File.mtime(helpers).to_i if File.exist? helpers
        @folders.each do |folder|
          Dir[File.join(pwd, folder, '**/*.*')].each do |found|
            timestamps << File.mtime(found).to_i unless (File.directory?(found) || is_font?( found ))
          end
        end
        timestamps.sort.last
      end
      
      def is_font?( file )
        case File.extname( file )
        when '.eot', '.ttf', '.woff', '.svg', '.otf'
          true
        else
          false
        end
      end

    end
  end
end
