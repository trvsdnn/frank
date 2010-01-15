Frank
=========

Inspired by [Sinatra][0]'s simplicity and ease of use, Frank lets you build
static sites using your favorite libs, painlessly. It uses [Tilt][1], so it
comes with support for [Haml & Sass][2], [Builder][3], [ERB][4],
[Liquid][5], & [Mustache][6].

Frank also supports [CoffeeScript][7] for writing JavaScript in style, and
[LESS][8] is planned for the near future.

Overview
--------

Create a new project with:

    $ frank <project_name>

Then start up the server with:
    
    $ frankup

    -----------------------
     Frank's holdin' it down...
     0.0.0.0:3601

And you're ready to get to work. Feel free to use as much or a little of
the available libs as you please. Frank works just as well with Mustache /
CSS / JavasScript as Haml / Sass / CoffeeScript.


Views & Layouts
-------------------------

All of your templates, and less/sass/coffeescript go into `<project>/dynamic`,
by default. You are more than welcome to organize them into subfolders if you've
got lots.

### Views

Writing views is simple. Say you've got a `blog.haml`, in `<project>/dynamic` just browse to
`http://0.0.0.0:3601/blog` and your view will be parsed and returned as html.

### Layouts

Layouts are also simple with Frank. By default, just create a `layout.haml`
(or whichever language you like best), that contains a `yield`, and any
views will be inserted into it at that point.

Multiple layouts are also easy. In your `settings.yml`, do something like:

    layouts:
        - name: blog_layout
          only: [blog]
        - name: normal
          not: [blog, ajax]
This tells Frank to use `blog_layout.haml` for `/blog`, and `normal.haml`
for everything but `/blog' and '/ajax`.


Partials & Helpers
------------------

Frank comes with a helper method, `render_partial`, for including partials
in your views.

In addition, you can also easily add your own helper methods to use.

### Partials

To create a partial, make a new file like any of your other views, but
prefix its name with an underscore.

For example, if I have a partial named `_footer.haml`, I can include this
in my Haml views like this:

    = render_partial 'footer'

### Helpers

Helper methods are also easy. Just open up `helpers.rb` and add your methods
to the `FrankHelpers` module; that's it. Use them just like `render_partial`.


GET/POST params
---------------

Sometimes it's nice to include user input in your mock-ups. It's especially
handy when mocking-up Ajax-driven elements. For this reason, the `request`
and `params` are available in your templates.

For example, to use a person's name submitted through a form you might do:

    %h1= "Hello, #{params.name}"

Configuration
-------------

In `settings.yml`, you can change your folder names, and server port & host name.
Check the comments there if you need help.

Once you've gotten comfortable with Frank, you will probably no longer want
the example files included whenever you start a new project. You may also have
preferred folder names, and languages that you always want to start
projects with.

To do this, create a new base project. Then just copy your base project to `~/.frank`.
This folder will then be copied for you whenever you run the `frank` command.
  
Installation
------------

### [Gemcutter](http://gemcutter.org/)

    $ gem install frank


[0]: http://www.sinatrarb.com/
[1]: http://github.com/rtomayko/tilt
[2]: http://haml-lang.com/
[3]: http://builder.rubyforge.org/
[4]: http://www.ruby-doc.org/stdlib/libdoc/erb/rdoc/
[5]: http://www.liquidmarkup.org/
[6]: http://github.com/defunkt/mustache
[7]: http://jashkenas.github.com/coffee-script/
[8]: http://lesscss.org/
[9]: http://rack.rubyforge.org/