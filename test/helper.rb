require 'stringio'
require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'shoulda'
require 'template/helpers'

require File.join(File.dirname(__FILE__), '../lib/frank')

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
