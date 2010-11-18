require File.dirname(__FILE__) + '/helper'

describe Frank::Compile do
  include Rack::Test::Methods

  context 'default output' do
    before :all do
      bin_dir    = File.join(File.dirname(File.dirname(__FILE__)), 'bin', 'frank export')
      proj_dir   = File.join(File.dirname(__FILE__), 'template')
      output_dir = File.join(proj_dir, 'output')
      Dir.chdir proj_dir do
        system "#{bin_dir} #{output_dir} > /dev/null"
      end
    end

    it 'creates the output folder' do
      File.exist?(File.join(File.dirname(__FILE__), 'template/output')).should be_true
    end

    it 'creates index.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/index.html')
      File.read(output).should == "<div id='p'>/</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/</h2>\n</div>\n"
    end

    it 'creates partial_test.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/partial_test.html')
      File.read(output).should == "<div id='p'>/partial_test</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/partial_test</h2>\n  <p>hello from partial</p>\n</div>\n"
    end

    it 'creates partial_locals_test.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/partial_locals_test.html')
      File.read(output).should == "<div id='p'>/partial_locals_test</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/partial_locals_test</h2>\n  <p>hello from local</p>\n</div>\n"
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

    it 'creates coffee.js' do
      output = File.join(File.dirname(__FILE__), 'template/output/coffee.js')
      File.read(output).should == "(function(){\n  var greeting;\n  greeting = \"Hello CoffeeScript\";\n})();"
    end

    it 'creates erb.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/erb.html')
      File.read(output).should == "<div id='p'>/erb</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
    end

    it 'creates redcloth.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/redcloth.html')
      File.read(output).should == "<div id='p'>/redcloth</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
    end

    it 'creates markdown.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/markdown.html')
      File.read(output).should == "<div id='p'>/markdown</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
    end

    it 'creates liquid.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/liquid.html')
      File.read(output).should == "<div id='p'>/liquid</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
    end

    it 'creates builder.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/builder.html')
      File.read(output).should == "<div id='p'>/builder</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
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
    before :all do
      bin_dir    = File.join(File.dirname(File.dirname(__FILE__)), 'bin', 'frank export')
      proj_dir   = File.join(File.dirname(__FILE__), 'template')
      output_dir = File.join(proj_dir, 'output')
      Dir.chdir proj_dir do
        system "#{bin_dir} #{output_dir} --production > /dev/null"
      end
    end

    it 'creates the output folder' do
      File.exist?(File.join(File.dirname(__FILE__), 'template/output')).should be_true
    end

    it 'creates index.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/index.html')
      File.read(output).should == "<div id='p'>/</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/</h2>\n</div>\n"
    end

    it 'creates partial_test.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/partial_test/index.html')
      File.read(output).should == "<div id='p'>/partial_test</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/partial_test</h2>\n  <p>hello from partial</p>\n</div>\n"
    end

    it 'creates partial_locals_test.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/partial_locals_test/index.html')
      File.read(output).should == "<div id='p'>/partial_locals_test</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/partial_locals_test</h2>\n  <p>hello from local</p>\n</div>\n"
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

    it 'creates	coffee.js' do
      output = File.join(File.dirname(__FILE__), 'template/output/coffee.js')
      File.read(output).should == "(function(){\n  var greeting;\n  greeting = \"Hello CoffeeScript\";\n})();"
    end

    it 'creates erb.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/erb/index.html')
      File.read(output).should == "<div id='p'>/erb</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
    end

    it 'creates redcloth.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/redcloth/index.html')
      File.read(output).should == "<div id='p'>/redcloth</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
    end

    it 'creates markdown.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/markdown/index.html')
      File.read(output).should == "<div id='p'>/markdown</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
    end

    it 'creates liquid.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/liquid/index.html')
      File.read(output).should == "<div id='p'>/liquid</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
    end

    it 'creates builder.html' do
      output = File.join(File.dirname(__FILE__), 'template/output/builder/index.html')
      File.read(output).should == "<div id='p'>/builder</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
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
