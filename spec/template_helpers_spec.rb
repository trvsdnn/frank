require File.dirname(__FILE__) + '/helper'

describe Frank::TemplateHelpers do
  include Rack::Test::Methods

  def app
    Frank.bootstrap(File.join(File.dirname(__FILE__), 'template'))
    require File.join(Frank.root, 'helpers')
    Frank.new do
      set :environment, :test
    end
  end

  before(:all) do
    @app = app
  end

  it 'render haml and use hello_helper' do
    template = @app.render('helper_test.haml')
    template.should == "<div id='p'>/helper_test</div>\n<div id='layout'>\n  <h1>hello from helper</h1>\n</div>\n"
  end

  it 'should render the refresh javascript' do
    template = @app.render('refresh.haml')
    template.should include("<script type=\"text/javascript\">\n            (function(){")
  end

  context 'Lorem' do
    it 'render haml with 3 random lorem words' do
      template = @app.render('lorem_test.haml')
      reg = /<p class='words'>(?:\w+\s?){3}<\/p>/
      template.should =~ reg
    end

    it 'render haml with 2 random lorem sentences' do
      template = @app.render('lorem_test.haml')
      reg = /<p class='sentences'>(?:[^.]+.){2}<\/p>/
      template.should =~ reg
    end

    it 'render haml with 1 random lorem paragraph' do
      template = @app.render('lorem_test.haml')
      reg = /<p class='paragraphs'>(?:[^\n]+(?:\n\n)?){1}<\/p>/m
      template.should =~ reg
    end

    it 'render haml with lorem name' do
      template = @app.render('lorem_test.haml')
      reg = /<p class='name'>[\w']+\s[\w']+<\/p>/m
      template.should =~ reg
    end

    it 'render haml with lorem email' do
      template = @app.render('lorem_test.haml')
      reg = /<p class='email'>[\w-]+@\w+\.\w+<\/p>/m
      template.should =~ reg
    end

    it 'render haml with lorem date' do
      template = @app.render('lorem_test.haml')
      reg = /<p class='date'>\d{4}-\d{2}-\d{2}<\/p>/m
      template.should =~ reg
    end

    it 'render image url using imager' do
      template = @app.render('lorem_test.haml')
      reg = /<img src='\/_img\/400x300.jpg\?random\d{5}' \/>/
      template.should =~ reg
    end
  end

end
