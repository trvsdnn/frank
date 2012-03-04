module Frank
  module Publish
    class Base

      attr_accessor :username, :password
      attr_accessor :hostname, :port
      attr_accessor :remote_path
      attr_accessor :local_path


      def initialize(options)
        @username = options.user || options.username
        @password = options.password
        @hostname = options.host
        @remote_path = options.path
        @port = options.port
        @local_path = "/tmp/frank-publish-#{Frank.proj_name}-#{Time.now.to_i}"
      end

      ##
      # Performs the backup transfer
      def perform!
        export!
        begin
          transfer!
        rescue SocketError
          err_message "Transfer failed. SocketError. Do you have internet?"
        end
        cleanup!
      end


      private

      def export!
        # remove stale folder if it exists
        FileUtils.rm_rf(local_path) if File.exist?(local_path)

        # dump the project in production mode to tmp folder
        Frank.export.path = @local_path
        Frank.export.silent = true
        Frank::Compile.export!
      end


      ##
      # returns a local_path relative list of all files to transfer for this export
      def files_to_transfer
        list = []
        return list unless File.exist?(local_path)

        Dir.chdir(local_path) do
          list = Dir.glob("**/*").map do |f|
            f unless File.directory? f
          end.compact!
        end

        list
      end

      ##
      # returns a local_path relative list of all directories to export
      def directories
        list = []
        return list unless File.exist?(local_path)

        Dir.chdir(local_path) do
          list = Dir.glob("**/*").map do |f|
            f if File.directory? f
          end.compact!
        end

        list
      end

      def cleanup!
        FileUtils.rm_rf(@local_path)
      end

      # ZOMG, we a need a Logger or sth.
      def ok_message *args
        Frank::Publish.ok_message *args
      end

      def err_message *args
        Frank::Publish.err_message *args
      end


    end


  end
end
