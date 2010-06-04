require File.dirname(__FILE__) + '/helper'

describe Frank::Base do
  include Rack::Test::Methods 
  
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
  
  it 'has all of the required settings set' do
    app.proj_dir.should_not be_nil
    app.server.should_not be_nil
    app.static_folder.should_not be_nil
    app.dynamic_folder.should_not be_nil
    app.layouts_folder.should_not be_nil
  end
  
  it 'renders a dynamic template given a request' do
    get '/'
    
    last_response.should be_ok
    last_response.body.should == "<div id='p'>/</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/</h2>\n</div>\n"
  end
  
  it 'renders a nested template given a request' do
    get '/nested/child'
    
    last_response.should be_ok
    last_response.body.should == "<div id='nested_layout'>\n  <h1>hello from child</h1>\n</div>\n"
  end
  
  it 'renders a dynamic template with an explicit layout' do
    get '/layout_test'
    
    last_response.should be_ok
    last_response.body.should == "<div id='layout2'>\n  <h1>hi inside layout2</h1>\n</div>\n"
  end
  
  it 'renders dynamic css without a layout' do
    get '/sass.css'
    
    last_response.should be_ok
    last_response.body.should == "#hello-worlds {\n  background: red; }\n"
  end
  
  it 'renders dynamic javascript without a layout' do
    get '/coffee.js'
    
    last_response.should be_ok
    last_response.body.should == "(function(){\n  var greeting;\n  greeting = \"Hello CoffeeScript\";\n})();"
  end
  
  it 'renders a 404 page if template not found' do
    get '/not_here.css'
                            
    last_response.should_not be_ok
    last_response.content_type.should == 'text/html'
    last_response.body.should =~ /Not Found/
  end
  
  it 'renders a 500 page for error' do
    capture_stdout { get '/500' }
    
    last_response.should_not be_ok
    last_response.content_type.should == 'text/html'
    last_response.body.should =~ /undefined local variable or method `non_method'/
  end
  
  it 'stubs out a project' do
    out = capture_stdout { Frank.stub('stubbed') }
    Dir.entries('stubbed').should == Dir.entries(File.join(LIBDIR, 'template'))
    response = "\nFrank is...\n - \e[32mCreating\e[0m your project 'stubbed'\n - \e[32mCopying\e[0m Frank template\n\n \e[32mCongratulations, 'stubbed' is ready to go!\e[0m\n"
    out.string.should == response
  end
  
  after(:all) do
    FileUtils.rm_r File.join(Dir.pwd, 'stubbed')
  end

end