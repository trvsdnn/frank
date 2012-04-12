module Frank
  module Publish

    #TODO

    class ShellSCP


      def self.shell_copy(local_dir, remote_dir, options)

        host = []
        command = ["scp "]
        command << "-P #{options[:port]} " if options[:port]
        command << "-r #{local_dir}/* "
        host << "#{options[:username]}" if options[:username]
        host << ":#{options[:password]}" if options[:password]
        host << "@#{options[:host]}:#{remote_dir}"

        shell_command = "#{command.join('')}#{host.join('')}"
        system(shell_command)

      end


    end


  end
end
