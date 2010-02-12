require File.dirname(__FILE__) + '/helper'

class TestBase < Test::Unit::TestCase
  
  def app
    settings = YAML.load_file('template/settings.yml')
    Frank.new do
      settings.each do |name, value|
        set name.to_s, value
      end
      set :environment, :test
      set :proj_dir, File.join(Dir.pwd, 'template')
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
      assert_equal "<h1>hello worlds</h1>\n\n", last_response.body
    end
    
    should 'render 404 page if template not found' do
      get '/not_here'
                              
      assert !last_response.ok?                          
      assert_match 'Not Found', last_response.body
    end
    
    should 'render 500 page for error' do
      get '/?brok=en'
      
      assert !last_response.ok?
      assert_match "undefined local variable or method `non_method'", last_response.body
    end
    
  end
  
end