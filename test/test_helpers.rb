require File.dirname(__FILE__) + '/helper'

class TestBase < Test::Unit::TestCase

  context 'Frank::Base' do
    
    setup do
      settings = YAML.load_file('template/settings.yml')
      @frank = Frank.new do
        settings.each do |name, value|
          set name.to_s, value
        end
        set :environment, :test
        set :proj_dir, File.join(Dir.pwd, 'template')
      end
    end
    
    should 'render haml and use hello_helper' do
      template = @frank.render_path('helper_test.haml')
      assert_equal "<h1>hello from helper</h1>\n", template
    end
    
  end
  
end