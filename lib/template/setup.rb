# ----------------------
#  Server settings:
#
#  Change the server host/port to bind rack to.
#
Frank.server.hostname = "0.0.0.0"
Frank.server.port = "3601"

# ----------------------
#  Markup folder:
#
# Your templates (haml, erb, sass, less, html, css, js, etc)
# Frank 2 allows you to put dynamic templates and 
# static assets in the same folder.
#
Frank.site_folder = "site"

# ----------------------
#  Layouts folder:
#
#  Frank will look for layouts in this folder
#  the default layout is `default'
#  it respects nested layouts that correspond to nested
#  folders in the `dynamic_folder'
#  for example: a template: `dynamic_folder/blog/a-blog-post.haml'
#  would look for a layout: `layouts/blog/default.haml'
#  and if not found use the default: `layouts/default.haml'
#
#  Frank also supports defining layouts on an
#  individual template basis using meta data
#  you can do this by defining a meta field `layout: my_layout.haml'
#
Frank.layouts_folder = "layouts"

# ----------------------
# Export settings:
#
# Projects will be exported to default to the following directory
#
Frank.export.path = "exported"

# ----------------------
#  Publish settings:
#
#  Frank can publish your exported project to
#  a server. All you have to do is tell Frank what host, path, and username.
#  If you have ssh keys setup there is no need for a password.
#  Just uncomment the Publish settings below and
#  make the appropriate changes.
#
#  Frank.publish.host = "example.com"
#  Frank.publish.path = "/www"
#  Frank.publish.username = 'me'
#  Frank.publish.password = 'secret'
#  Frank.publish.port = 22
#

# ----------------------
# Sass Options:
# Frank.sass_options = { :load_paths => [ File.join(File.dirname(__FILE__), 'dynamic/css') ] }


# ----------------------
# Initializers:
#
# Add any other project setup code, or requires here
# ....
