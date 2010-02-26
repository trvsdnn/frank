require File.dirname(__FILE__) + '/helper'

class TestBase < Test::Unit::TestCase

  context 'Frank::TemplateHelpers' do
    
    setup do
      proj_dir = File.join(File.dirname(__FILE__), 'template')
      settings = YAML.load_file(File.join(proj_dir, 'settings.yml'))
      require File.join(proj_dir, 'helpers')
      @frank = Frank.new do
        settings.each do |name, value|
          set name.to_s, value
        end
        set :environment, :test
        set :proj_dir, proj_dir
      end
    end
    
    should 'render haml and use hello_helper' do
      template = @frank.render_path('helper_test.haml')
      assert_equal "<div id='layout'>\n  <h1>hello from helper</h1>\n</div>\n", template
    end
    
    context 'Lorem' do
      should 'render haml with 3 random lorem words' do
        template = @frank.render_path('lorem_test.haml')
        reg = /<p class='words'>(?:\w+\s?){3}<\/p>/
        assert_match reg, template
      end
    
      should 'render haml with 2 random lorem sentences' do
        template = @frank.render_path('lorem_test.haml')
        reg = /<p class='sentences'>(?:[^.]+.){2}<\/p>/
        assert_match reg, template
      end
      
      should 'render haml with 1 random lorem paragraph' do
        template = @frank.render_path('lorem_test.haml')
        reg = /<p class='paragraphs'>(?:[^\n]+(?:\n\n)?){1}<\/p>/m
        assert_match reg, template
      end
      
      should 'render image url using imager' do
        template = @frank.render_path('lorem_test.haml')
        reg = /<img src='\/_img\/400x300.jpg\?random' \/>/
        assert_match reg, template
      end
    end
    
  end
  
end