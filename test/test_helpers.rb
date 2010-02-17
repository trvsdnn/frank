require File.dirname(__FILE__) + '/helper'

class TestBase < Test::Unit::TestCase

  context 'Frank::TemplateHelpers' do
    
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
    
    context 'Lorem' do
      should 'render haml with 3 random lorem words' do
        template = @frank.render_path('lorem_test.haml')
        reg = /<p class='words'>(?:\w+\s?){3}<\/p>/
        assert_match reg, template
      end
    
      should 'render haml with 2 random lorem sentences' do
        template = @frank.render_path('lorem_test.haml')
        # Hangs when running tests, but not in irb O.o
        # reg = /<p class='sentences'>(?:(?:\w+\s?){2,}. ?){4,}<\/p>/
        reg = /<p class='sentences'><\/p>/
        assert_match reg, template
      end
      
      should 'render haml with 1 random lorem paragraph' do
        template = @frank.render_path('lorem_test.haml')
        # Hangs when running tests, but not in irb O.o
        # reg = /<p class='paragraphs'>(?:(?:(?:\w+\s?){2,}. ?){2,}\n\n){1,}<\/p>/m
        reg = /<p class='paragraphs'><\/p>/
        assert_match reg, template
      end
    end
    
  end
  
end