require 'find'

module Frank
  class Output < Frank::Base
    include Frank::Render
    
    attr_accessor :environment, :proj_dir, :static_folder, :dynamic_folder, :templates, :output_folder
    
    def initialize(&block)
      instance_eval &block
    end
    
    # get all of the templates and compile them
    def compile_templates(options)
      dir = File.join(@proj_dir, @dynamic_folder)
      layouts = templates['layouts'].map { |l| l['name'] }
      
      Find.find(dir) do |path|
        if FileTest.file?(path) && !File.basename(path).match(/^(\.|_)/)
          # get the path name
          path = path[ dir.size + 1 ..-1 ]
          # get name and ext
          name, ext = name_ext(path)
          # get output extension
          new_ext = reverse_ext_lookup(ext)

          # if production is true and this template isn't a layout
          if options[:production] == true && !layouts.include?(name)
            # if template isn't index or template doesn't compile to html
            # then compile it as is, otherwise name a folder based on the template
            # and compile to index.html
            if "#{name}.#{new_ext}" == 'index.html' || new_ext != 'html'
              new_file = File.join(@output_folder, "#{name}.#{new_ext}")
            else
              new_file = File.join(@output_folder, name, "index.#{new_ext}")
              name = "#{name}/index"
            end
            create_dir(new_file)
            File.open(new_file, 'w') {|f| f.write render_path(path) }
          elsif options[:production] == false
            new_file = File.join(@output_folder, "#{name}.#{new_ext}")  
            create_dir(new_file)
            File.open(new_file, 'w') {|f| f.write render_path(path) }
          end
          puts " - \033[32mCreating\033[0m '#{@output_folder}/#{name}.#{new_ext}'"
        end
      end
    end
    
    # use path to determine folder name and
    # create the required folder if it doesn't exist
    def create_dir(path)
      FileUtils.makedirs path.split('/').reverse[1..-1].reverse.join('/')
    end
    
    # copies over static content
    def copy_static
      puts " - \033[32mCopying\033[0m static content"
      static_folder = File.join(@proj_dir, @static_folder)
      FileUtils.cp_r(File.join(static_folder, '/.'), @output_folder) 
    end
    
    # create the dump dir, compile templates, copy over static assets
    def dump(options={:production => false})
      FileUtils.mkdir(@output_folder)
      puts "\nFrank is..."
      puts " - \033[32mCreating\033[0m '#{@output_folder}'"
      
      compile_templates(options)
      copy_static
      puts "\n \033[32mCongratulations, project dumped to '#{@output_folder}' successfully!\033[0m"
    end
  end
  
end