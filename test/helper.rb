require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'shoulda'
require 'template/helpers'

require File.join(File.dirname(__FILE__), '../lib/frank')

class Test::Unit::TestCase
  include Rack::Test::Methods 

end
