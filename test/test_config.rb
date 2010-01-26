require File.dirname(__FILE__) + '/helper'

class TestConfig < Test::Unit::TestCase
  context "loading configuration" do
    setup do
      @path = 'template/settings.yml'
    end
 
    should "load config file" do
      assert File.exists?(@path)
    end
 
    # should "load configuration as hash" do
    #   mock(YAML).load_file(@path) { Hash.new }
    #   mock($stdout).puts("Configuration from #{@path}")
    #   assert_equal Jekyll::DEFAULTS, Jekyll.configuration({})
    # end
    #  
    # should "fire warning with bad config" do
    #   mock(YAML).load_file(@path) { Array.new }
    #   mock($stderr).puts("WARNING: Could not read configuration. Using defaults (and options).")
    #   mock($stderr).puts("\tInvalid configuration - #{@path}")
    #   assert_equal Jekyll::DEFAULTS, Jekyll.configuration({})
    # end
  end
end