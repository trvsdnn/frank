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
    
    should 'have all required settings set' do
      assert_not_nil @frank.proj_dir
      assert_not_nil @frank.server
      assert_not_nil @frank.static_folder
      assert_not_nil @frank.dynamic_folder
      assert_not_nil @frank.templates
    end
    
    should 'respond to call' do
      assert_respond_to @frank, :call
    end
    
    should 'render a dynamic template given a request' do
      request = Rack::MockRequest.new(@frank)
      response = request.get('/', {'SERVER_NAME' => 'localhost', 'SERVER_PORT' => '3601'})
      assert response.ok?
      
      assert_match 'hello worlds', response.body
    end
    
    should 'render 404 page if template not found' do
       request = Rack::MockRequest.new(@frank)
       response = request.get('/not_here', 
                              { 'SERVER_NAME' => 'localhost', 
                                'SERVER_PORT' => '3601', 
                                'REQUEST_PATH' => '/not_here'} )
                              
       assert !response.ok?                          
       assert_match 'Not Found', response.body
    end
    
    should 'render 500 page for error' do
        request = Rack::MockRequest.new(@frank)
        response = request.get('/?blah=broken',
                               { 'SERVER_NAME' => 'localhost', 
                                 'SERVER_PORT' => '3601', 
                                 'REQUEST_PATH' => '/'})
        
        assert !response.ok?
        assert_match "<tt>can't convert Fixnum into String</tt>", response.body
    end
    
  end
  
end