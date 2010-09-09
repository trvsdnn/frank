require 'net/scp'

module Frank
  class Publish

    def self.execute!
      puts "\033[32mPublishing to:\033[0m `#{Frank.publish.host}:#{Frank.publish.path}/#{Frank.proj_name}'"
      tmp_folder = "/tmp/frankexp-#{Frank.proj_name}"

      # remove stale folder if it exists
      FileUtils.rm_rf(tmp_folder) if File.exist?(tmp_folder)

      # dump the project in production mode to tmp folder
      # set verbose to false
      Frank::Output.new do
        set :environment, :output
        set :output_folder, tmp_folder
      end.dump(verbose = false)

      # upload the files and report progress
      Net::SCP.start(Frank.publish.host, Frank.publish.user) do |scp|
        scp.upload!(tmp_folder, Frank.publish.path, :recursive => true) do |ch, name, sent, total|
          puts " - #{name}: #{sent}/#{total}"
        end
      end

      # cleanup by removing tmp folder
      FileUtils.rm_rf(tmp_folder)

      puts "\033[32mPublish complete!\033[0m"
    end

  end
end