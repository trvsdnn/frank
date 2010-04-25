require File.dirname(__FILE__) + '/helper'

class TestBase < Test::Unit::TestCase

  context 'Frank::Base' do
    
    setup do
      proj_dir = File.join(File.dirname(__FILE__), 'template')
      settings = YAML.load_file(File.join(proj_dir, 'settings.yml'))
      @frank = Frank.new do
        settings.each do |name, value|
          set name.to_s, value
        end
        set :environment, :test
        set :proj_dir, proj_dir
      end
    end
    
    context 'layouts' do
      
      should 'render template using layout' do
        template = @frank.render_path('layout_test.haml')
        assert_equal "<div id='layout'>\n  <h1>hi inside layout</h1>\n</div>\n", template
      end
      
      should 'render template using layout2' do
        template = @frank.render_path('layout2_test.haml')
        assert_equal "<div id='layout2'>\n  <h1>hi inside layout2</h1>\n</div>\n", template
      end
      
      should 'render rdiscount template inside haml layout' do
        template = @frank.render_path('markdown_in_haml.md')
        assert_equal "<div id='layout'>\n  <h1>hi inside layout</h1>\n</div>\n", template
      end
      
    end
    
    should 'render haml template' do
     template = @frank.render_path('index.haml')
     assert_equal "<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n", template
    end
    
    should 'render haml template with a haml partial' do
      template = @frank.render_path('partial_test.haml')
      assert_equal "<div id='layout'>\n  <h1>hello worlds</h1>\n  <p>hello from partial</p>\n</div>\n", template
    end
    
    should 'render sass template' do
      template = @frank.render_path('sass.sass')
      assert_equal "#hello-worlds {\n  background: red; }\n", template
    end
    
    should 'render coffee template' do
      template = @frank.render_path('coffee.coffee')
      assert_equal "(function(){\n  var greeting;\n  greeting = \"Hello CoffeeScript\";\n})();", template
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
    
    should 'raise template error' do
      assert_raise(Frank::TemplateError) { @frank.render_path('not_a.template') }
    end
      
  end
  
end