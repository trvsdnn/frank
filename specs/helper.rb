require 'bundler'
Bundler.setup

require 'minitest/spec'
require 'minitest/autorun'
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