# ----------------------
#  Server settings:
#
#  Change the server host/port to bind rack to.
# 'server' can be any Rack-supported server, e.g.
#  Mongrel, Thin, WEBrick
#
Frank.server.handler = "mongrel"
Frank.server.hostname = "0.0.0.0"
Frank.server.port = "3601"

# ----------------------
#  Static folder:
#
#  All files in this folder will be served up
#  directly, without interpretation
#
Frank.static_folder = "static"

# ----------------------
#  Dynamic folder:
#
#  Frank will try to interpret any of the files
#  in this folder based on their extension
#
Frank.dynamic_folder = "dynamic"

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
# Initializers:
#
# Add any other project setup code, or requires here
# ....