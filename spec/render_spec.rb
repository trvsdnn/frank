require File.dirname(__FILE__) + '/helper'

describe Frank::Render do
  include Rack::Test::Methods

  def app
    Frank.bootstrap(File.join(File.dirname(__FILE__), 'template'))
    Frank.new
  end

  before(:all) do
    @app = app
  end

  it 'renders a template using layout' do
    template = @app.render('index.haml')
    template.should == "\n<div id='p'>/</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/</h2>\n</div>\n"
  end

  it 'renders a template using layout2' do
    template = @app.render('layout2_test.haml')
    template.should == "<div id='layout2'>\n  <h1>hi inside layout2</h1>\n</div>\n"
  end

  it 'renders a markdown template inside haml layout' do
    template = @app.render('markdown_in_haml.md')
    template.should == "\n<div id='p'>/markdown_in_haml</div>\n<div id='layout'>\n  <h1>hi inside layout</h1>\n</div>\n"
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
     template.should == "\n<div id='p'>/</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/</h2>\n</div>\n"
   end

   it 'renders haml template with a haml partial' do
     template = @app.render('partial_test.haml')
     template.should == "\n<div id='p'>/partial_test</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/partial_test</h2>\n  <p>hello from partial</p>\n</div>\n"
   end

   it 'renders a partial with locals' do
     template = @app.render('partial_locals_test.haml')
     template.should == "\n<div id='p'>/partial_locals_test</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n  <h2>/partial_locals_test</h2>\n  <p>hello from local</p>\n</div>\n"
   end
   
   it 'renders less template' do
     template = @app.render('stylesheets/less.less')
     template.should include("#hello-worlds { background: red; }")
   end

   it 'renders sass template' do
     template = @app.render('stylesheets/sass.sass')
     template.should include("#hello-worlds {\n  background: red;\n}\n")
   end

   it 'renders sass with compass reset' do
     template = @app.render('stylesheets/sass_with_compass.sass')
     template.should include("h1, h2, h3, h4, h5, h6, p, blockquote, pre,\n")
   end

   it 'renders scss with compass mixin' do
     template = @app.render('stylesheets/scss_with_compass.scss')
     template.should include("-moz-border-radius: 5px;\n")
     template.should include("-webkit-border-radius: 5px;\n")
     template.should include("border-radius: 5px;\n")
   end

   it 'renders coffee template' do
      template = @app.render('coffee.coffee')
      template.should == "(function() {\n  ({\n    greeting: \"Hello CoffeeScript\"\n  });\n}).call(this);\n"
   end

   it 'renders erb template' do
     template = @app.render('erb.erb')
     template.should == "\n<div id='p'>/erb</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
   end

   it 'renders redcloth template' do
     template = @app.render('redcloth.textile')
     template.should == "\n<div id='p'>/redcloth</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
   end

   it 'renders rdiscount template' do
     template = @app.render('markdown.md')
     template.should == "\n<div id='p'>/markdown</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
   end

   it 'renders liquid template' do
     template = @app.render('liquid.liquid')
     template.should == "\n<div id='p'>/liquid</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
   end

   it 'renders builder template' do
     template = @app.render('builder.builder')
     template.should == "\n<div id='p'>/builder</div>\n<div id='layout'>\n  <h1>hello worlds</h1>\n</div>\n"
   end

   it 'raise template error' do
     lambda { @app.render('not_a.template') }.should raise_error(Frank::TemplateError)
   end

end
