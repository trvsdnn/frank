Frank
=========

Inspired by [Sinatra][0]'s simplicity and ease of use, Frank lets you build
static sites using your favorite libs. Frank has a built in development server
for previewing work as you develop. Frank also has a "dump" command for compiling and saving
your work out to static html and css.

Frank uses [Tilt][1], so it
comes with support for [Haml & Sass][2], [LESS][10], [Builder][3], [ERB][4],
[Liquid][5], and [Mustache][6].

Overview
--------

Create a new project with:

    $ frank <project_name>

Then `cd <project_name>` and start up the server with:
  
    $ frankup

    -----------------------
     Frank's holdin' it down...
     0.0.0.0:3601

And you're ready to get to work. By default, dynamic templates are served from the `dynamic` folder, 
static files are served from the `static` folder, and layouts are served from the `layouts` folder.

When you're done working:

    $ frankout <dump_dir>

to compile templates and copy them--along with static your assets--into `<dump_dir>`. Or,
    
    $ frankout --production <dump_dir>

to compile & copy over, but organized to work as a static website in production. (e.g. folders named after your views, with an `index.html` inside)

Views & Meta Data
-------------------------

All of your templates, less, sass &c. go into `<project>/dynamic` by default.
You can organize them into subfolders if you've got lots.

### Views

Writing views is simple. Say you've got a `blog.haml` in `<project>/dynamic`; just browse over to
`http://0.0.0.0:3601/blog` and your view will be parsed and served up as html.


### Meta Data

Frank was designed to make controllers unnecessary. But, sometimes it's nice to have
variables in your templates / layouts. This is particularly handy if you want to set the page
title (in the layout) according to the view. This is simple, now, with meta data.

Meta fields go at the top of any view, and are written in [YAML][13]. To mark the end
of the meta section, place the meta delimeter, `META---`, on a blank line. You can
use as many hyphens as you'd like (as long as there are 3).

Meta fields are then available as local variables to all templating languages that
support them--in the view & layout:

    view:
      title: My Rad Page
      author: My Rad Self
      ---------------------------------------------META
      
      %h1= title
      %h3= 'By ' + author
      
    layout:
      %title= title + '--My Rad Site'
    


Layouts (updated in 0.3)
-----------------------------

Layouts are also simple with Frank. Create a `default.haml` (or `.rhtml`, etc.),
in the `layouts` folder, and include a `yield` somewhere therein; views using the
layout will be inserted there.

### Namespacing Layouts
You can namespace your layouts using folders:

  * When rendering a view--`dynamic_folder/blog/a-blog-post.haml`,
  * Frank would first look for the layout `layouts/blog/default.haml`,
  * and if not found use fall back on `layouts/default.haml`

### Multiple/No Layouts

Frank also supports choosing layouts on a view-by-view basis via meta data. Just add a
`layout` meta field:

    layout: my_layout.haml
    ---------------------------------------------META
    %h1 I'm using my_layout.haml instead of default.haml!

or if you don't want a layout at all:

    layout: nil
    ---------------------------------------------META
    %h1 No layout here!



Partials & Helpers
------------------

Frank comes with a helper method, `render_partial`, for including partials
in your views.

You can also add your own helper methods easily.

### Partials

To create a partial, make a new file like any of your other views, but
prefix its name with an underscore.

For example, if I have a partial named `_footer.haml`, I can include this
in my Haml views like this:

    = render_partial 'footer'

### Helpers

Helper methods are also easy. Just open up `helpers.rb` and add your methods
to the `FrankHelpers` module; that's it. Use them just like `render_partial`.



Built-in Helpers
----------------

### Auto-Refresh

Frank now has a handy automatic page refreshing helper. Just include `= refresh`
(or equivalent) in your view, and Frank will automatically refresh the page for you whenever you
save a project file. This eliminates the tedium of hundreds of manual refreshes over the course
of building a project.

When it's time to `frankout`, Frank will leave out the JavasScript bits of the refresher.

### Current Page

Frank now has a `current_page` variable that you can use to set selected states on nav items.
It will return the path info from the template being processed. You also, have access to the variable from layouts and from the `frankout` command.

### Placeholder Text

You can easily generate dummy text like so:

     %p= lorem.sentences 3

This will return 3 sentences of standard [Lorem Ipsum][11]. `lorem` also has all of the following methods for generating dummy text:

     lorem.sentence     # returns a single sentence
     lorem.words 5      # returns 5 individual words
     lorem.word
     lorem.paragraphs 10
     lorem.paragraph
     lorem.date         # accepts a strftime format argument
     lorem.name
     lorem.first_name
     lorem.last_name
     lorem.email
     

### Placeholder Images

Likewise, Frank can generate placeholder images for you, from a selection of 10 pre-made images. For example, to generate `<img />` tag with a random dummy image:
     
     %img{:src=> lorem.image( 500, 400 ) }

The `lorem.image` helper returns a special Frank image URL. In this case, the returned image will be 500 pixels wide and 400 pixels tall. By default, Frank caches the images returned for each specific size. So every subsequent request for a `500x400` image will return the same thing. If you'd rather have a random image every time, just pass in `true` for the 3rd image:
     
     lorem.image( 100, 100, true )    # returns a random 100x100 image every time it's called

( NOTE: Unfortunately, in order to use the placeholder images, you must have a working [ImageMagick][12], and have the `mini_magick` gem installed as well. )

If you would like to use the placeholder images in a context where the helper methods are unavailable (e.g. in static CSS or JavaScript), you can access the URL directly with `/_img/500x400.jpg`, or for random images `/_img/500x400.jpg?random`.

### Replacement Text

All of the lorem helpers accept an optional "replacement" argument. This will be the text rendered when you `frankout`.
For example `lorem.sentence("<%= page.content %>")` will generate a lorem sentence when you view the page using the `frankup` server.
However, when you `frankout` the template will render "<%= page.content %>". This is useful if you plan on moving a frank project
into a framework. (e.g. rails, sinatra, django, etc)


Configuration
-------------

In `settings.yml`, you can change your folder names, and server port & host name.
Check the comments there if you need help.

(NOTE: In order to reduce confusion, Frank no longer checks for a `~/.frank` folder to copy when you run the `frank` command. Instead, the preferred method is just to create a base Frank project wherever you please, and just `cp -r` to the location of your new project, since this is all the `frank` command did anyway)
  
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
[8]: http://lesscss.org/
[9]: http://rack.rubyforge.org/
[10]: http://lesscss.org/
[11]: http://en.wikipedia.org/wiki/Lorem_ipsum
[12]: http://www.imagemagick.org/script/binary-releases.php?ImageMagick=4pg9cdfr8e6gn7aru9mtelepr3
[13]: http://www.yaml.org/start.html