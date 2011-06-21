testdir = File.dirname(__FILE__)
$:.unshift testdir unless $LOAD_PATH.include?(testdir)

require 'bundler'
Bundler.setup

require 'stringio'
require 'rack/test'
require 'template/helpers'
require 'frank'

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
