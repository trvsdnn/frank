Frank
=========

Inspired by [Sinatra][0]'s simplicity and ease of use, Frank lets you build
static sites using your favorite libs. Frank has a built in development server
for previewing work as you develop, an "export" command for compiling and saving
your work out to static html and css, and a publish command for copying your
exported pages to a server.

Frank uses [Tilt][1], so it
comes with support for [Haml & Sass][2], [LESS][10], [Builder][3], [ERB][4], and
[Liquid][5].

Overview
--------

Create a new project with:

    $ frank new <project_path>

Then `cd <project_path>` and start up the server with:

    $ frank server

    -----------------------
     Frank's holdin' it down...
     0.0.0.0:3601

And you're ready to get to work. By default, dynamic templates are served from the `dynamic` folder,
static files are served from the `static` folder, and layouts are served from the `layouts` folder.

When you're done working:

    $ frank export <export_dir>

to compile templates and copy them--along with static your assets--into `<export_dir>` (or to `export/` if you don't specify an `<export_dir>`).

Or,

    $ frank export --production <export_dir>

to compile & copy over, but organized to work as a static website in production. (e.g. folders named after your views, with an `index.html` inside)

You can add publish settings in setup.rb and publish directly to a server via scp.

    $ frank publish

Upgrading
-------------------------

As of version 0.4, Frank no longer uses settings.yml. However you can use `frank upgrade` in order convert your old settings.yml to the new setup.rb format.


Frank Templates
-------------------------

Frank (as of 1.0) has support for saving "templates" in `~/.frank_templates`. This is very handy if find yourself wanting a custom starting point. All you have to do to use the feature is create a `~/.frank_templates` folder and start putting templates in it.

Once you have a few templates saved, when you run `frank new <project_path>` you'll be presented with a list of templates to choose from as the starting point for the project.

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

You can also send local variables to partials like this:

    = render_partial 'footer', :local_variable_name => 'some_value'

### Helpers

Helper methods are also easy. Just open up `helpers.rb` and add your methods
to the `FrankHelpers` module; that's it. Use them just like `render_partial`.



Built-in Helpers
----------------

### Auto-Refresh

Frank has a handy automatic page refreshing helper. Just include `= refresh`
(or equivalent) in your view, and Frank will automatically refresh the page for you whenever you
save a project file. This eliminates the tedium of hundreds of manual refreshes over the course
of building a project.

When it's time export with `frank export`, Frank will leave out the JavasScript bits of the refresher.

### Current Path

Frank now has a `current_path` variable that you can use to set selected states on nav items.
It will return the path info from the template being processed. You also, have access to the variable from layouts and from the `frank export` command.

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

Frank now uses [placehold.it][14] for placeholder images, the `lorem.image` helper supports background_color, color, random_color, and text options:

     lorem.image('300x400')                                               #=> http://placehold.it/300x400
     lorem.image('300x400', :background_color => '333', :color => 'fff')  #=> http://placehold.it/300x400/333/fff
     lorem.image('300x400', :random_color => true)                        #=> http://placehold.it/300x400/f47av7/9fbc34d
     lorem.image('300x400', :text => 'blah')                              #=> http://placehold.it/300x400&text=blah

### Replacement Text

All of the lorem helpers accept an optional "replacement" argument. This will be the text rendered when you `frank export`.

For example `lorem.sentence("<%= page.content %>")` will generate a lorem sentence when you view the page using the `frank server` for development.
However, when you `frank export` the template will render "<%= page.content %>". This is useful if you plan on moving a frank project
into a framework. (e.g. rails, sinatra, django, etc)


Configuration
-------------

In `setup.rb`, you can change your folder names, and server port & host name.
Check the comments there if you need help.

Installation
------------

    $ gem install frank


Contributors (in no particular order)
-------------------------------------

* railsjedi (Jacques Crocker)
* asymmetric (Lorenzo Manacorda)
* timmywil (timmywil)
* sce (Sten Christoffer Eliesen)
* btelles (Bernie Telles)
* mitchellbryson (Mitchell Bryson)
* nwah (Noah Burney)


[0]: http://www.sinatrarb.com/
[1]: http://github.com/rtomayko/tilt
[2]: http://haml-lang.com/
[3]: http://builder.rubyforge.org/
[4]: http://www.ruby-doc.org/stdlib/libdoc/erb/rdoc/
[5]: http://www.liquidmarkup.org/
[8]: http://lesscss.org/
[9]: http://rack.rubyforge.org/
[10]: http://lesscss.org/
[11]: http://en.wikipedia.org/wiki/Lorem_ipsum
[12]: http://www.imagemagick.org/script/binary-releases.php?ImageMagick=4pg9cdfr8e6gn7aru9mtelepr3
[13]: http://www.yaml.org/start.html
[14]: http://placehold.it
