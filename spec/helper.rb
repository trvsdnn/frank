testdir = File.dirname(__FILE__)
$:.unshift testdir unless $LOAD_PATH.include?(testdir)

require "bundler"
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
