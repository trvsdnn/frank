require File.dirname(__FILE__) + '/helper'

class TestBase < Test::Unit::TestCase

  context 'Frank::Base' do
    
    setup do
      settings = YAML.load_file('template/settings.yml')
      @frank = Frank::Output.new do
        settings.each do |name, value|
          set name.to_s, value
        end
        set :environment, :test
        set :proj_dir, File.join(Dir.pwd, 'template')
        set :output_folder, 'output'
      end.dump
    end
    
    should 'create the output folder' do
      assert File.exist? 'template/output'
    end
    
    should 'create index.html' do
      assert_equal "<h1>hello worlds</h1>\n\n", IO.read('template/output/index.html')
    end
    
    should  'create partial_test.html' do
      assert_equal "<h1>hello worlds</h1>\n<p>hello from partial</p>\n", IO.read('template/output/partial_test.html')   
    end
    
    should 'create erb.html' do
      assert_equal "<h1>hello worlds</h1>\n", IO.read('template/output/erb.html')
    end
    
    should 'create redcloth.html' do
      assert_equal "<h1>hello worlds</h1>", IO.read('template/output/redcloth.html')
    end
    
    should 'create markdown.html' do
      assert_equal "<h1>hello worlds</h1>\n", IO.read('template/output/markdown.html')
    end
    
    should 'create mustache.html' do
      assert_equal "<h1>hello worlds</h1>\n", IO.read('template/output/mustache.html')
    end
    
    should 'create liquid.html' do
      assert_equal "<h1>hello worlds</h1>", IO.read('template/output/liquid.html')
    end
    
    should 'create builder.html' do
      assert_equal "<h1>hello worlds</h1>\n", IO.read('template/output/builder.html')
    end
    
    should 'copy static.html' do
      assert_equal "hello from static", IO.read('template/output/static.html')
    end
    
    teardown do
      FileUtils.rm_r File.join(Dir.pwd, 'template/output')
    end

    
  end
  
end