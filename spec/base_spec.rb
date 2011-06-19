require File.dirname(__FILE__) + '/helper'

describe Frank::Base do
  include Rack::Test::Methods

  def app
    Frank.bootstrap(File.join(File.dirname(__FILE__), 'template'))
    Frank.new do
      # this is just used for a test
      @blowup_sometimes = true
    end
  end

  it 'has all of the required settings set' do
    app
    Frank.root.should_not be_nil
    Frank.server.handler.should_not be_nil
    Frank.server.hostname.should_not be_nil
    Frank.server.port.should_not be_nil
    Frank.static_folder.should_not be_nil
    Frank.dynamic_folder.should_not be_nil
    Frank.layouts_folder.should_not be_nil
  end

  it 'renders a dynamic template given a request' do
    get '/'

    last_response.should be_ok
    last_response.body.should == "<div id='p'>/</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/</h2>\n</div>\n"
  end

  it 'renders a page and uses a helper' do
    get '/helper_test'

    last_response.should be_ok
    last_response.body.should == "<div id='p'>/helper_test</div>\n<div id='layout'>\n  <h1>hello from helper</h1>\n</div>\n"
  end

  it 'renders a nested template given a request' do
    get '/nested/child'

    last_response.should be_ok
    last_response.body.should == "<div id='nested_layout'>\n  <h1>hello from child</h1>\n</div>\n"
  end

  it 'renders dynamic css without a layout' do
    get '/stylesheets/sass.css'

    last_response.should be_ok
    last_response.body.should include("#hello-worlds {\n  background: red;\n}\n")
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
