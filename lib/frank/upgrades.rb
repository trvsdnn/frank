module Frank
  module Upgrades

    def upgrade!
      version = detect_version

      if version == '0.3'
        upgrade_from_0_3!
      else
        puts "\033[32mLooks like you're already good to go!\033[0m"
      end
    end

    private

    def upgrade_from_0_3!
      settings   = YAML.load_file(File.join(Frank.root, 'settings.yml'))
      setup      = <<-SETUP
      # ----------------------
      #  Server settings:
      #
      #  Change the server host/port to bind rack to.
      # 'server' can be any Rack-supported server, e.g.
      #  Mongrel, Thin, WEBrick
      #
      Frank.server.handler = "#{settings['server']['handler']}"
      Frank.server.hostname = "#{settings['server']['hostname']}"
      Frank.server.port = "#{settings['server']['port']}"

      # ----------------------
      #  Static folder:
      #
      #  All files in this folder will be served up
      #  directly, without interpretation
      #
      Frank.static_folder = "#{settings['static_folder']}"

      # ----------------------
      #  Dynamic folder:
      #
      #  Frank will try to interpret any of the files
      #  in this folder based on their extension
      #
      Frank.dynamic_folder = "#{settings['dynamic_folder']}"

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
      Frank.layouts_folder = "#{settings['layouts_folder']}"


      # ----------------------
      # Initializers:
      #
      # Add any other project setup code, or requires here
      # ....
      SETUP

      puts " - \033[32mConverting\033[0m settings.yml => setup.rb"

      File.open(File.join(Frank.root, 'setup.rb'), 'w') { |file| file.write(setup.gsub(/^\s+(?=[^\s])/, '')) }
      File.delete(File.join(Frank.root, 'settings.yml'))

      puts "\n \033[32mUpdate is complete, enjoy!\033[0m"
    end

    def detect_version
      if File.exist? File.join(Frank.root, 'settings.yml')
        version = '0.3'
      else
        version = '<0.3'
      end

      version
    end

  end
end