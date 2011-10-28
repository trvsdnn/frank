require File.expand_path('../helper', __FILE__)

describe Frank::Base do
    include Rack::Test::Methods
    
    def app
      Frank.bootstrap(File.expand_path('../template', __FILE__))
      Frank.new
    end
    
    it 'has all of the required settings set' do
      app
      Frank.root.wont_be_nil
      Frank.server.hostname.wont_be_nil
      Frank.server.port.wont_be_nil
      Frank.site_folder.wont_be_nil
      Frank.layouts_folder.wont_be_nil
    end
    
    it 'renders a dynamic template given a request' do
      get '/'
    
      last_response.ok?.must_equal true
      last_response.body.strip.must_equal "<div id='p'>/</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/</h2>\n</div>"
    end
    
    it 'renders a static template given a request' do
      get '/files/static'
    
      last_response.ok?.must_equal true
      last_response.body.strip.must_equal "<div id='p'>/</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/</h2>\n</div>"
    end
    
    it 'renders a page and uses a helper' do
      get '/helper_test'
    
      last_response.ok?.must_equal true
      last_response.body.strip.must_equal "<div id='p'>/helper_test</div>\n<div id='layout'>\n  <h1>hello from helper</h1>\n</div>"
    end
    
    it 'renders a nested template given a request' do
      get '/nested/child'
    
      last_response.ok?.must_equal true
      last_response.body.strip.must_equal "<div id='nested_layout'>\n  <h1>hello from child</h1>\n</div>"
    end
    
    it 'renders dynamic css without a layout' do
      get '/stylesheets/sass.css'
    
      last_response.ok?.must_equal true
      last_response.body.must_include "#hello-worlds {\n  background: red;\n}"
    end
    
    it 'renders a 404 page if template not found' do
      get '/not_here.css'
      
      last_response.ok?.must_equal false
      last_response.content_type.must_equal 'text/html'
      last_response.body.must_match(/Not Found/)
    end
    
    it 'renders a 500 page for error' do
      skip 'figure out a better way to test this'
      capture_stdout { get '/500' }
      last_response.ok?.must_equal false
      last_response.content_type.must_equal 'text/html'
      last_response.body.must_match(/undefined local variable or method `non_method'/)
    end
    
    it 'stubs out a project' do
      skip 'figure out a better way to test this'
      out = capture_stdout { Frank.stub('stubbed') }
      Dir.entries('stubbed').must_equal Dir.entries(File.join(LIBDIR, 'template'))
      response = "\nFrank is...\n - \e[32mCreating\e[0m your project 'stubbed'\n - \e[32mCopying\e[0m Frank template\n\n \e[32mCongratulations, 'stubbed' is ready to go!\e[0m\n"
      out.string.must_equal == response
      FileUtils.rm_r File.join(Dir.pwd, 'stubbed')
    end

end
 