testdir = File.dirname(__FILE__)
$:.unshift testdir unless $LOAD_PATH.include?(testdir)

require 'rubygems' if RUBY_VERSION < '1.9'
require 'bundler/setup'

require 'stringio'
require 'rack/test'
require 'template/helpers'
require 'frank'
require 'frank/publish/base'

module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out
  ensure
    $stdout = STDOUT
  end
end

module Frank
  module Spec
    module Helpers
      BIN_DIR = File.join(File.dirname(File.dirname(__FILE__)), 'bin')

      def frank(command, *args)
        result = system "#{BIN_DIR}/frank #{command} #{args * ' '}"

        if $?.success?
          result
        else
          exit 1
        end
      end
    end
  end
end

module Frank
  module Publish
    def self.ok_message str, prefix = "";
    end

    def self.err_message str, prefix = "";
    end
  end
end

RSpec.configure do |config|
  ##
  # Use Mocha to mock with RSpec
  config.mock_with :mocha

end
