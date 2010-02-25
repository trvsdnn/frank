testdir = File.dirname(__FILE__)
$LOAD_PATH.unshift testdir unless $LOAD_PATH.include?(testdir)
 
libdir = File.dirname(File.dirname(__FILE__)) + '/lib'
$LOAD_PATH.unshift libdir unless $LOAD_PATH.include?(libdir)

require 'stringio'
require 'rubygems'
require 'yaml'
require 'test/unit'
require 'rack/test'
require 'shoulda'
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

class Test::Unit::TestCase
  include Rack::Test::Methods 
end
