require File.dirname(__FILE__) + '/helper'

class TestBase < Test::Unit::TestCase
  
  def app
    proj_dir = File.join(File.dirname(__FILE__), 'template')
    settings = YAML.load_file(File.join(proj_dir, 'settings.yml'))
    Frank.new do
      settings.each do |name, value|
        set name.to_s, value
      end
      set :environment, :test
      set :proj_dir, proj_dir
    end
  end
  
  context 'Frank::Base' do
    
    should 'have all required settings set' do
      assert_not_nil app.proj_dir
      assert_not_nil app.server
      assert_not_nil app.static_folder
      assert_not_nil app.dynamic_folder
      assert_not_nil app.templates
    end
    
    should 'render a dynamic template given a request' do
      get '/'
      
      assert last_response.ok?
      assert_equal "<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n", last_response.body
    end
    
    should 'render dynamic css without a layout' do
      get '/sass.css'
      
      assert last_response.ok?
      assert_equal "#hello-worlds {\n  background: red; }\n", last_response.body
    end
    
    should 'render dynamic javascript without a layout' do
      get '/coffee.js'
      
      assert last_response.ok?
      assert_equal "(function(){\n  var greeting;\n  greeting = \"Hello CoffeeScript\";\n})();", last_response.body
    end
    
    should 'render 404 page if template not found' do
        get '/not_here.css'
                                
        assert !last_response.ok?
        assert_equal 'text/html', last_response.content_type                          
        assert_match 'Not Found', last_response.body
      end
      
      should 'render 500 page for error' do
        get '/?brok=en'
        
        assert !last_response.ok?
        assert_equal 'text/html', last_response.content_type
        assert_match "undefined local variable or method `non_method'", last_response.body
      end
      
    end
    
    context 'Frank.stub' do
      
      should 'stub out a project' do
        out = capture_stdout { Frank.stub('stubbed') }
        assert_equal Dir.entries('stubbed'), Dir.entries(File.join(LIBDIR, 'template'))
        putss = "\nFrank is...\n - \e[32mCreating\e[0m your project 'stubbed'\n - \e[32mCopying\e[0m Frank template\n\n \e[32mCongratulations, 'stubbed' is ready to go!\e[0m\n"
        assert_equal putss, out.string
      end
    
      teardown do
        FileUtils.rm_r File.join(Dir.pwd, 'stubbed')
      end
    
    end
  
end