require File.dirname(__FILE__) + '/helper'

class TestBase < Test::Unit::TestCase

  context 'Frank::Output' do
    
    setup do
      proj_dir = File.join(File.dirname(__FILE__), 'template')
      settings = YAML.load_file(File.join(proj_dir, 'settings.yml'))
      require File.join(proj_dir, 'helpers')
      capture_stdout do
        @frank = Frank::Output.new do
          settings.each do |name, value|
            set name.to_s, value
          end
          set :environment, :test
          set :proj_dir, proj_dir
          set :output_folder, 'output'
        end.dump
      end
    end
    
    should 'create the output folder' do
      assert File.exist? File.join(File.dirname(__FILE__), 'template/output')
    end
    
    should 'create index.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/index.html')
      assert_equal "<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n", IO.read(output)
    end
    
    should  'create partial_test.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/partial_test.html')
      assert_equal "<div id='layout'>\n  <h1>hello worlds</h1>\n  <p>hello from partial</p>\n</div>\n", IO.read(output)   
    end
    
    should 'create erb.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/erb.html')
      assert_equal "<h1>hello worlds</h1>\n", IO.read(output)
    end
    
    should 'create redcloth.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/redcloth.html')
      assert_equal "<h1>hello worlds</h1>", IO.read(output)
    end
    
    should 'create markdown.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/markdown.html')
      assert_equal "<h1>hello worlds</h1>\n", IO.read(output)
    end
    
    should 'create mustache.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/mustache.html')
      assert_equal "<h1>hello worlds</h1>\n", IO.read(output)
    end
    
    should 'create liquid.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/liquid.html')
      assert_equal "<h1>hello worlds</h1>", IO.read(output)
    end
    
    should 'create builder.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/builder.html')
      assert_equal "<h1>hello worlds</h1>\n", IO.read(output)
    end
    
    should 'copy static.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/static.html')
      assert_equal "hello from static", IO.read(output)
    end
    
    should 'not create partials' do
      assert !File.exist?(File.join(File.dirname(__FILE__), 'template/output/_partial.html'))
    end
    
    teardown do
      FileUtils.rm_r File.join(File.dirname(__FILE__), 'template/output')
    end
  end
  
  context 'Frank::Output Production' do
    
    setup do
      proj_dir = File.join(File.dirname(__FILE__), 'template')
      settings = YAML.load_file(File.join(proj_dir, 'settings.yml'))
      require File.join(proj_dir, 'helpers')
      
      capture_stdout do
        @frank = Frank::Output.new do
          settings.each do |name, value|
            set name.to_s, value
          end
          set :environment, :test
          set :proj_dir, proj_dir
          set :output_folder, 'output'
        end.dump({:production => true})
      end
    end
    
    should 'create the output folder' do
      assert File.exist? File.join(File.dirname(__FILE__), 'template/output')
    end
    
    should 'create index.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/index.html')
      assert_equal "<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n", IO.read(output)
    end
    
    should  'create partial_test.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/partial_test/index.html')
      assert_equal "<div id='layout'>\n  <h1>hello worlds</h1>\n  <p>hello from partial</p>\n</div>\n", IO.read(output)   
    end
    
    should 'create erb.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/erb/index.html')
      assert_equal "<h1>hello worlds</h1>\n", IO.read(output)
    end
    
    should 'create redcloth.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/redcloth/index.html')
      assert_equal "<h1>hello worlds</h1>", IO.read(output)
    end
    
    should 'create markdown.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/markdown/index.html')
      assert_equal "<h1>hello worlds</h1>\n", IO.read(output)
    end
    
    should 'create mustache.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/mustache/index.html')
      assert_equal "<h1>hello worlds</h1>\n", IO.read(output)
    end
    
    should 'create liquid.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/liquid/index.html')
      assert_equal "<h1>hello worlds</h1>", IO.read(output)
    end
    
    should 'create builder.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/builder/index.html')
      assert_equal "<h1>hello worlds</h1>\n", IO.read(output)
    end
    
    should 'copy static.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/static.html')
      assert_equal "hello from static", IO.read(output)
    end
    
    should 'not create partials' do
      assert !File.exist?(File.join(File.dirname(__FILE__), 'template/output/_partial/index.html'))
    end
    
    teardown do
      FileUtils.rm_r File.join(File.dirname(__FILE__), 'template/output')
    end
  
    
  end
  
end