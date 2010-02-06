require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'shoulda'
require 'template/helpers'

require File.join(File.dirname(__FILE__), '../lib/frank')

class Test::Unit::TestCase
  include Rack::Test::Methods

  LIBDIR = File.join(File.dirname(File.dirname(__FILE__)), 'lib')
  
  def mock_app(&block)
    @app = Frank.new(&block)
  end
  
  def app
    Rack::Lint.new(@app)
  end
  
  def body
    response.body.to_s
  end
  

end
