require File.dirname(__FILE__) + '/helper'

describe Frank::Output do
  include Rack::Test::Methods 
  
  context 'default output' do
    before(:all) do
      proj_dir = File.join(File.dirname(__FILE__), 'template')
      settings = YAML.load_file(File.join(proj_dir, 'settings.yml'))
      require File.join(proj_dir, 'helpers')
      capture_stdout do
        Frank::Output.new do
          settings.each do |name, value|
            set name.to_s, value
          end
          set :environment, :output
          set :proj_dir, proj_dir
          set :output_folder, File.join(File.dirname(__FILE__), 'template/output')
        end.dump
      end
    end
  
    it 'creates the output folder' do
      File.exist?(File.join(File.dirname(__FILE__), 'template/output')).should be_true
    end
      
    it 'creates index.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/index.html')
      File.read(output).should == "<div id='p'>/</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/</h2>\n</div>\n"
    end
      
    it  'creates partial_test.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/partial_test.html')
      File.read(output).should == "<div id='p'>/partial_test</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <p>hello from partial</p>\n</div>\n"
    end
    
    it 'creates child.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/nested/child.html')
      File.read(output).should == "<div id='nested_layout'>\n  <h1>hello from child</h1>\n</div>\n"
    end
    
    it 'creates deep.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/nested/deeper/deep.html')
      File.read(output).should == "<div id='nested_layout'>\n  <h1>really deep</h1>\n</div>\n"
    end
    
    it 'creates no_layout.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/no_layout.html')
      File.read(output).should == "<h1>i have no layout</h1>\n"
    end
      
    it 'creates erb.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/erb.html')
      File.read(output).should == "<h1>hello worlds</h1>\n\n"
    end
      
    it 'creates redcloth.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/redcloth.html')
      File.read(output).should == "<h1>hello worlds</h1>"
    end
      
    it 'creates markdown.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/markdown.html')
      File.read(output).should == "<h1>hello worlds</h1>\n"
    end
      
    it 'creates mustache.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/mustache.html')
      File.read(output).should == "<h1>hello worlds</h1>\n\n"
    end
      
    it 'creates liquid.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/liquid.html')
      File.read(output).should == "<h1>hello worlds</h1>\n"
    end
      
    it 'creates builder.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/builder.html')
      File.read(output).should == "<h1>hello worlds</h1>\n"
    end
      
    it 'copies static.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/files/static.html')
      File.read(output).should == "hello from static"
    end
      
    it "doesn't create partials" do
      File.exist?(File.join(File.dirname(__FILE__), 'template/output/_partial.html')).should be_false
    end
    
    it 'handles lorem replacement fields' do
      output = File.join(File.dirname(__FILE__), 'template/output/lorem_test.html')
      File.read(output).should include("<p class='words'>replace-this</p>")
      File.read(output).should include("<p class='sentences'>replace-this</p>")
      File.read(output).should include("<p class='paragraphs'>replace-this</p>")
      File.read(output).should include("<p class='date'>replace-this</p>")
      File.read(output).should include("<p class='name'>replace-this</p>")
      File.read(output).should include("<p class='email'>replace-this</p>")
      File.read(output).should include("<img src='replace-this' />")
    end
    
    it 'should not render the refresh js' do
      output = File.join(File.dirname(__FILE__), 'template/output/refresh.html')
      File.read(output).should == "<div id='p'>/refresh</div>\n<div id='layout'>\n  \n</div>\n"
    end
    
    after(:all) do
      FileUtils.rm_r File.join(File.dirname(__FILE__), 'template/output')
    end
  
  end
  
  context 'productions output' do
    before(:all) do
      proj_dir = File.join(File.dirname(__FILE__), 'template')
      settings = YAML.load_file(File.join(proj_dir, 'settings.yml'))
      require File.join(proj_dir, 'helpers')
      capture_stdout do
        Frank::Output.new do
          settings.each do |name, value|
            set name.to_s, value
          end
          set :environment, :output
          set :proj_dir, proj_dir
          set :output_folder, File.join(File.dirname(__FILE__), 'template/output')
        end.dump(production=true)
      end
    end
  
    it 'creates the output folder' do
      File.exist?(File.join(File.dirname(__FILE__), 'template/output')).should be_true
    end
  
    it 'creates index.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/index.html')
      File.read(output).should == "<div id='p'>/</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/</h2>\n</div>\n"
    end
  
    it  'creates partial_test.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/partial_test/index.html')
      File.read(output).should == "<div id='p'>/partial_test</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <p>hello from partial</p>\n</div>\n"
    end
    
    it 'creates child.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/nested/child/index.html')
      File.read(output).should == "<div id='nested_layout'>\n  <h1>hello from child</h1>\n</div>\n"
    end
    
    it 'creates deep.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/nested/deeper/deep/index.html')
      File.read(output).should == "<div id='nested_layout'>\n  <h1>really deep</h1>\n</div>\n"
    end
    
    it 'creates no_layout.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/no_layout/index.html')
      File.read(output).should == "<h1>i have no layout</h1>\n"
    end
  
    it 'creates erb.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/erb/index.html')
      File.read(output).should == "<h1>hello worlds</h1>\n\n"
    end
  
    it 'creates redcloth.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/redcloth/index.html')
      File.read(output).should == "<h1>hello worlds</h1>"
    end
  
    it 'creates markdown.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/markdown/index.html')
      File.read(output).should == "<h1>hello worlds</h1>\n"
    end
  
    it 'creates mustache.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/mustache/index.html')
      File.read(output).should == "<h1>hello worlds</h1>\n\n"
    end
  
    it 'creates liquid.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/liquid/index.html')
      File.read(output).should == "<h1>hello worlds</h1>\n"
    end
  
    it 'creates builder.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/builder/index.html')
      File.read(output).should == "<h1>hello worlds</h1>\n"
    end
  
    it 'copies static.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/files/static.html')
      File.read(output).should == "hello from static"
    end
  
    it "doesn't create partials" do
      File.exist?(File.join(File.dirname(__FILE__), 'template/output/_partial/index.html')).should be_false
    end
    
    it 'handles lorem replacement fields' do
      output = File.join(File.dirname(__FILE__), 'template/output/lorem_test/index.html')
      File.read(output).should include("<p class='words'>replace-this</p>")
      File.read(output).should include("<p class='sentences'>replace-this</p>")
      File.read(output).should include("<p class='paragraphs'>replace-this</p>")
      File.read(output).should include("<p class='date'>replace-this</p>")
      File.read(output).should include("<p class='name'>replace-this</p>")
      File.read(output).should include("<p class='email'>replace-this</p>")
      File.read(output).should include("<img src='replace-this' />")
    end
    
    it 'should not render the refresh js' do
      output = File.join(File.dirname(__FILE__), 'template/output/refresh/index.html')
      File.read(output).should == "<div id='p'>/refresh</div>\n<div id='layout'>\n  \n</div>\n"
    end
  
    after(:all) do
      FileUtils.rm_r File.join(File.dirname(__FILE__), 'template/output')
    end
    
  end
  
end