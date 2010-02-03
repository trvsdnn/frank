require File.dirname(__FILE__) + '/helper'

class TestBase < Test::Unit::TestCase

  context 'Frank::Base' do
    
    setup do
      settings = YAML.load_file('template/settings.yml')
      @frank = Frank.new do
        settings.each do |name, value|
          set name.to_s, value
        end
      end
    end
    
    should 'render haml template' do
      template = @frank.render_path('index.haml')
      assert_equal "<h1>hello worlds</h1>\n", template
    end
    
    should 'render sass template' do
      template = @frank.render_path('sass.sass')
      assert_equal "#hello-worlds {\n  background: red; }\n", template
    end
    
    should 'render erb template' do
      template = @frank.render_path('erb.erb')
      assert_equal "<h1>hello worlds</h1>\n", template
    end

    should 'render redcloth template' do
      template = @frank.render_path('redcloth.textile')
      assert_equal "<h1>hello worlds</h1>", template
    end
    
    should 'render rdiscount template' do
      template = @frank.render_path('markdown.md')
      assert_equal "<h1>hello worlds</h1>\n", template
    end
    
    should 'render mustache template' do
      template = @frank.render_path('mustache.mustache')
      assert_equal "<h1>hello worlds</h1>\n", template
    end
    
    should 'render liquid template' do
      template = @frank.render_path('liquid.liquid')
      assert_equal "<h1>hello worlds</h1>", template
    end
    
    should 'render builder template' do
      template = @frank.render_path('builder.builder')
      assert_equal "<h1>hello worlds</h1>\n", template
    end
    
  end
  
end