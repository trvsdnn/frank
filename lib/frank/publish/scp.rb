require 'frank/publish/base'
require 'net/ssh'
require 'net/scp'


module Frank
  module Publish
    class SCP < Base

      def initialize(options, &block)
        super(options)
        instance_eval(&block) if block_given?

        @port ||= 22
      end


      def connection
        Net::SCP.start(hostname, username, :password => password) do |scp|
          yield scp
        end
      end

      def transfer!
        connection do |scp|
          old_name = ''
          scp.upload! local_path, remote_path do |ch, name|
            if old_name != name
              ok_message "Uploading #{name}", "    - "
            end
          end
        end
      end

    end
  end
end
