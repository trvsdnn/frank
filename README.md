Frank
=========

Inspired by [Sinatra][0]'s simplicity and ease of use, Frank lets you build
static sites using your favorite libs. Frank has a built in development server
for previewing work as you develop. Frank also has a "dump" command for compiling and saving
your work out to static html, css, and js.

Frank uses [Tilt][1], so it
comes with support for [Haml & Sass][2], [LESS][10], [Builder][3], [ERB][4],
[Liquid][5], [Mustache][6], and [CoffeeScript][7].

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
static files are served from the `static` folder, and layouts are server from the `layouts` folder.

When you are finished:
    `$ frankout <dump_dir> # compile templates`
    
    or
    
    `$ frankout --production <dump_dir> # compile and create folder structure suitable for serving from a production website`

Views & Meta Data
-------------------------

All of your templates, and less/sass/coffeescript go into `<project>/dynamic`,
by default. You can organize them into subfolders if you've
got lots.

### Views

Writing views is simple. Say you've got a `blog.haml`, in `<project>/dynamic` just browse to
`http://0.0.0.0:3601/blog` and your view will be parsed and returned as html.

### Meta Data

Frank doesn't have controllers and there are times you need to pass variables around between templates and layouts.
This can be done with template Meta data. Meta data is set using YAML. 

You define your fields at the top a template
a separate it from the rest of your template using the Meta delimiter: `META--------`. The delimiter can contain as
many dashes, or hyphens as you wish.

You can access your fields as local variables in the template (if the template language supports it).
For example, you might have a template and define a field `title: My Rad Template`, then inside a haml layout,
 you could create a title tag with the field: `%title= title`

Layouts (updated in 0.3)
-----------------------------

Layouts are also simple with Frank. By default, just create a `default.haml`
(or another language), inside the `layouts` folder and include a `yield` statement. Any
views will be inserted into it at that point.

Layouts can be name spaced with folders:

a template: `dynamic_folder/blog/a-blog-post.haml`
would look for a layout: `layouts/blog/default.haml`
and if not found use the default: `layouts/default.haml`

Frank also supports defining layouts on an individual template basis using meta data
you can do this by defining a meta field `layout: my_layout.haml` You can disable layouts on a 
template by using `layout: nil`



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



Built-in Helpers
----------------

### Auto Refresh

Constantly refreshing your browser can become tedious while doing work. Frank has a handy refresh helper.
It will include a bit of javascript that refreshes the browser when you save the current template or it's layout.
You can include this in a haml template like this: `= refresh`. When you `frankout`,
 the template will render an empty string instead of the script tag


Frank also comes with some handy helper methods for generating placeholder content.

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
However, when you `frankout` the template will render "<%= page.content %>".


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
[7]: http://jashkenas.github.com/coffee-script/
[8]: http://lesscss.org/
[9]: http://rack.rubyforge.org/
[10]: http://lesscss.org/
[11]: http://en.wikipedia.org/wiki/Lorem_ipsum
[12]: http://www.imagemagick.org/script/binary-releases.php?ImageMagick=4pg9cdfr8e6gn7aru9mtelepr3