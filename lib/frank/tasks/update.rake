namespace :project do
  task :update do
    pwd        = Rake.original_dir
    setup_file = File.join(pwd, 'setup.rb')

    puts "\nFrank is...\n - \033[32mUpdating\033[0m your project"

    if File.exist? setup_file
      puts "\033[32mLooks like you're already good to go!\033[0m"
      exit
    else
      settings   = YAML.load_file(File.join(pwd, 'settings.yml'))
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

      File.open(setup_file, 'w') { |file| file.write(setup.gsub(/^\s+(?=[^\s])/, '')) }
      File.delete(File.join(pwd, 'settings.yml'))

      puts "\n \033[32mUpdate is complete, enjoy!\033[0m"
    end

  end
end
