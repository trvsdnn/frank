require File.dirname(__FILE__) + '/helper'

describe Frank::TemplateHelpers do
  include Rack::Test::Methods

  def app
    Frank.bootstrap(File.join(File.dirname(__FILE__), 'template'))
    require File.join(Frank.root, 'helpers')
    Frank.new
  end

  before(:all) do
    @app = app
  end

  it 'render haml and use hello_helper' do
    template = @app.render('helper_test.haml')
    template.should == "<div id='p'>/helper_test</div>\n<div id='layout'>\n  <h1>hello from helper</h1>\n</div>\n"
  end

  it 'sets an instance variable, which the layout should render correctly' do
    template = @app.render('setting_in_layout.haml')
    template.should == "<div id='title'>BLAH!</div>\n<div id='p'>/setting_in_layout</div>\n<div id='layout'>\n  <h1>hello</h1>\n</div>\n"
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

    it 'render haml with lorem date between 1910 and 1919' do
      template = @app.render('lorem_test.haml')
      reg = /<p class='date'>191(\d{1})-\d{2}-\d{2}<\/p>/m
      template.should =~ reg
    end

    it 'render image url using imager' do
      template = @app.render('lorem_test.haml')
      reg1 = /<img src='http:\/\/placehold\.it\/400x300' \/>/
      reg2 = /<img src='http:\/\/placehold\.it\/400x300\/[a-z0-9]{6}\/[a-z0-9]{6}' \/>/      
      reg3 = /<img src='http:\/\/placehold\.it\/400x300\/444\/eee' \/>/
      reg4 = /<img src='http:\/\/placehold\.it\/400x300\/ccc\/aaa' \/>/
      reg5 = /<img src='http:\/\/placehold\.it\/400x300\/444(&amp;|&)text=blah' \/>/

      template.should =~ reg1
      template.should =~ reg2
      template.should =~ reg3
      template.should =~ reg4
      template.should =~ reg5
    end
  end

end
