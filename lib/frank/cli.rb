require 'optparse'

module Frank
  class CLI
    BANNER = <<-USAGE
    Usage:
      frank new PROJECT_PATH
      frank server [options]
      frank export PATH [options]
      frank publish

    Description:
      The `frank new' command generates a frank template project with the default
      directory structure and configuration at the given path.

      Once you have a frank project you can use the `frank server' or the aliased 'frank up' commands
      to start the development server and begin developing your project.

      When you are finished working and ready to export you can use
      the `frank export' or aliased `frank out' commands.

    Example:
      frank new ~/Dev/blah.com
      cd ~/Dev/blah.com
      frank server

      # do some development

      # export it
      frank export ~/Dev/html/blah.com

      # or publish it
      frank publish
    USAGE

    class << self

      def set_options
        @options = {:server => {}}

        @opts = OptionParser.new do |opts|
          opts.banner = BANNER.gsub(/^\s{4}/, '')

          opts.separator ''
          opts.separator 'Options:'

          opts.on('--server [HANDLER]', 'Set the server handler (frank server)') do |handler|
            @options[:server]['handler'] = handler unless handler.nil?
          end

          opts.on('--hostname [HOSTNAME]', 'Set the server hostname (frank server)') do |hostname|
            @options[:server]['hostname'] = hostname unless hostname.nil?
          end

          opts.on('--port [PORT]', 'Set the server port (frank server)') do |port|
            @options[:server]['port'] = port unless port.nil?
          end

          opts.on('--dynamic_folder [FOLDER]', 'Set the dynamic folder (frank server)') do |folder|
            @options[:dynamic_folder] = folder unless folder.nil?
          end

          opts.on('--static_folder [FOLDER]', 'Set the static folder (frank server)') do |folder|
            @options[:static_folder] = folder unless folder.nil?
          end

          opts.on('--production', 'Production ready export (frank export) i.e. ([FOLDER]/index.html)') do |handler|
            @options[:production] = true
          end

          opts.on('-v', '--version', 'Show the frank version and exit') do
            puts "Frank v#{Frank::VERSION}"
            exit
          end

          opts.on( '-h', '--help', 'Display this help' ) do
            puts opts
            exit
          end
        end

        @opts.parse!
      end

      # parse and set options
      # bootstrap if we need to
      # and go go go
      def run
        set_options

        if ARGV.empty?
          print_usage_and_exit!
        else
          bootstrap
          run!
        end
      end

      # determine what the user wants us to do
      # and then, just do it
      def run!
        case ARGV.first
        when 'new', 'n'
          print_usage_and_exit! unless ARGV[1]
          # stub out the project
          Frank.stub(ARGV[1])
        when 'server', 's', 'up'
          # setup server from options
          server_options        = @options[:server]
          Frank.server.handler  = server_options['handler'] if server_options['handler']
          Frank.server.hostname = server_options['hostname'] if server_options['hostname']
          Frank.server.port     = server_options['port'] if server_options['port']
          if File.exist? 'setup.rb'
            # setup folder options if we have setup.rb
            Frank.dynamic_folder = @options[:dynamic_folder] if @options[:dynamic_folder]
            Frank.static_folder  = @options[:static_folder] if @options[:static_folder]
          else
            # let frank act like a real grown up server
            Frank.serving_static!
            Frank.dynamic_folder = '.'
            Frank.static_folder = '.'
          end
          Frank.new
        when 'export', 'e', 'out', 'compile'
          # compile the project
          Frank.exporting!
          Frank.production! if @options[:production]
          Frank.export.path = ARGV[1] if ARGV[1]
          Frank::Compile.export!
        when 'publish', 'p'
          # compile the project and scp it to server
          Frank.publishing!
          Frank::Publish::SCP.execute!
        when 'upgrade'
          # upgrade if we need to upgrade
          Frank.upgrade!
        else
          puts "frank doesn't know that one... `frank --help' for usage"
          exit
        end
      end

      # print the usage banner and exit
      def print_usage_and_exit!
        puts @opts
        exit
      end

      # bootstrap this project up
      # only if we really need to
      def bootstrap
        if %w[server up export out publish upgrade s e p].include? ARGV.first
          Frank.bootstrap(Dir.pwd)
        end
      end

    end

  end
end
