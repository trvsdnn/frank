module Frank
  module Publish


    def self.execute!
      protocol = exit_unless_configured.to_s

      ok_message "", "\nFrank is..."
      ok_message "Exporting templates", " - "

      # upload the files and report progress
      ok_message "Publishing to: `#{Frank.publish.host}:#{Frank.publish.path}' via #{protocol}", " - "


      req = "frank/publish/#{protocol.downcase}"
      rescue_load_error protocol do
        require req
        clazz = Frank::Publish.const_get(protocol.upcase)
        publisher = clazz.new(Frank.publish)
        publisher.perform!
      end

      ok_message "\nPublish complete!"
    end

    def self.exit_unless_configured
      required_settings = {:host => Frank.publish.host, :path => Frank.publish.path, :username => Frank.publish.username}

      should_exit = false
      message = ""

      protocol = Frank.publish.mode || :scp
      unless [:ftp, :ftptls, :sftp, :scp].include?(protocol.to_sym)
        message << "Frank.publish.mode = #{protocol} is not supported. Supported publish modes are 'ftp', 'ftptls', 'sftp' or 'scp' (default)\n"
        should_exit = true
      end

      required_settings.each do |name, value|
        if value.nil?
          message << "Frank.publish.#{name} is required to publish. You can configure it in setup.rb\n"
          should_exit = true
        end
      end


      if should_exit
        err_message message
        exit!
      end

      protocol
    end

    def self.rescue_load_error protocol, &blk
      gem = "net-#{protocol}"
      begin
        yield
      rescue LoadError
        err_message "Publishing via #{protocol} requires the '#{gem}' gem. `gem install #{gem}'"
        exit!
      end
    end


    def self.ok_message str, prefix = ''
      puts "#{prefix}\033[32m#{str}\033[0m"
    end

    def self.err_message str, prefix = ''
      puts "#{prefix}\033[31m#{str}\033[0m"
    end


  end

end
