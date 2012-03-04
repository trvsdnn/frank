require 'frank/publish/base'
require 'net/ftp'

module Frank
  module Publish

    class FTP < Base

      def initialize(options, &block)
        super(options)
        instance_eval(&block) if block_given?

        @port ||= 21
        @remote_path = remote_path.sub(/^\~\//, '').sub(/^\//, '')
      end

      private

      ##
      # Establishes a connection to the remote server
      #
      # Note:
      # Since the FTP port is defined as a constant in the Net::FTP class, and
      # might be required to change by the user, we dynamically remove and
      # re-add the constant with the provided port value
      def connection
        if Net::FTP.const_defined?(:FTP_PORT)
          Net::FTP.send(:remove_const, :FTP_PORT)
        end; Net::FTP.send(:const_set, :FTP_PORT, port)

        Net::FTP.open(hostname, username, password) do |ftp|
          ftp.passive = true
          yield ftp
        end
      end

      ##
      # Transfers the archived file to the specified remote server
      def transfer!
        connection do |ftp|
          directories.each do |dir|
            create_remote_path(File.join(remote_path, dir), ftp)
          end

          files_to_transfer.each do |file|
            ok_message "Uploading #{file}", "    - "
            ftp.put(
              File.join(local_path, file),
              File.join(remote_path, file)
            )
          end
        end
      end

      ##
      # Creates (if they don't exist yet) all the directories on the remote
      # server in order to upload the backup file. Net::FTP does not support
      # paths to directories that don't yet exist when creating new
      # directories. Instead, we split the parts up in to an array (for each
      # '/') and loop through that to create the directories one by one.
      # Net::FTP raises an exception when the directory it's trying to create
      # already exists, so we have rescue it
      def create_remote_path(remote_path, ftp)
        path_parts = []
        remote_path.split('/').each do |path_part|
          path_parts << path_part
          begin
            dir = path_parts.join('/')
            ftp.mkdir(dir) unless dir.empty?
          rescue Net::FTPPermError;
          end
        end
      end


    end


  end
end
