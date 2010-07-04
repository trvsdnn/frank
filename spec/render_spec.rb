require File.dirname(__FILE__) + '/helper'

describe Frank::Render do
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
  
  before(:all) do
    @app = app
  end
  
  it 'renders a template using layout' do
    template = @app.render('index.haml')
    template.should == "<div id='p'>/</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/</h2>\n</div>\n"
  end
  
  it 'renders a template using layout2' do
    template = @app.render('layout2_test.haml')
    template.should == "<div id='layout2'>\n  <h1>hi inside layout2</h1>\n</div>\n"
  end
  
  it 'renders a markdown template inside haml layout' do
    template = @app.render('markdown_in_haml.md')
    template.should == "<div id='p'>/markdown_in_haml</div>\n<div id='layout'>\n  <h1>hi inside layout</h1>\n</div>\n"
  end
  
  it 'renders a nested template with a nested layout' do
    template = @app.render('/nested/child.haml')
    template.should == "<div id='nested_layout'>\n  <h1>hello from child</h1>\n</div>\n"
  end
  
  it 'renders a deeply nested template with a nested layout' do
    template = @app.render('/nested/deeper/deep.haml')
    template.should == "<div id='nested_layout'>\n  <h1>really deep</h1>\n</div>\n"
  end
   
  it 'renders a haml template with no layout' do
     template = @app.render('no_layout.haml')
     template.should == "<h1>i have no layout</h1>\n"
   end
    
   it 'renders haml template' do
     template = @app.render('index.haml')
     template.should == "<div id='p'>/</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/</h2>\n</div>\n"
   end
   
   it 'renders haml template with a haml partial' do
     template = @app.render('partial_test.haml')
     template.should == "<div id='p'>/partial_test</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/partial_test</h2>\n  <p>hello from partial</p>\n</div>\n"
   end

   it 'renders a partial with locals' do
     template = @app.render('partial_locals_test.haml')
     template.should == "<div id='p'>/partial_locals_test</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/partial_locals_test</h2>\n  <p>hello from local</p>\n</div>\n"
   end
   
   it 'renders sass template' do
     template = @app.render('sass.sass')
     template.should == "#hello-worlds {\n  background: red; }\n"
   end
    
   it 'renders erb template' do
     template = @app.render('erb.erb')
     template.should == "<div id='p'>/erb</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
   end
   
   it 'renders redcloth template' do
     template = @app.render('redcloth.textile')
     template.should == "<div id='p'>/redcloth</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
   end
   
   it 'renders rdiscount template' do
     template = @app.render('markdown.md')
     template.should == "<div id='p'>/markdown</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
   end
   
   it 'renders mustache template' do
     template = @app.render('mustache.mustache')
     template.should == "<div id='p'>/mustache</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
   end
   
   it 'renders liquid template' do
     template = @app.render('liquid.liquid')
     template.should == "<div id='p'>/liquid</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
   end
   
   it 'renders builder template' do
     template = @app.render('builder.builder')
     template.should == "<div id='p'>/builder</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
   end
   
   it 'raise template error' do
     lambda { @app.render('not_a.template') }.should raise_error(Frank::TemplateError)
   end
   
end
