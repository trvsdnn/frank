module Frank
  class Output < Frank::Base
    include Frank::Render
    
    attr_accessor :environment, :proj_dir, :static_folder, :dynamic_folder, :templates, :output_folder
    
    def initialize(&block)
      instance_eval &block
    end
    
    # compile the templates
    # if production and template isn't index and is html    
    # name a folder based on the template and compile to index.html
    # otherwise compile as is
    def compile_templates(production)
      dir = File.join(@proj_dir, @dynamic_folder)
      
      Dir[File.join(dir, '**/*')].each do |path|
        if File.file?(path) && !File.basename(path).match(/^(\.|_)/)
          path    = path[ (dir.size + 1)..-1 ]
          ext     = File.extname(path)
          new_ext = ext_from_handler(ext)  
          name    = File.basename(path, ext)
          
          if production == true && "#{name}.#{new_ext}" != 'index.html' && new_ext == 'html'
            new_file = File.join(@output_folder, path.sub(/(\/?[\w-]+)\.[\w-]+$/, "\\1/index.#{new_ext}"))
          else
            new_file = File.join(@output_folder, path.sub(/\.[\w-]+$/, ".#{new_ext}"))  
          end
          
          create_dirs(new_file)
          File.open(new_file, 'w') {|f| f.write render(path) }
          puts " - \033[32mCreating\033[0m '#{new_file}'"
        end
      end
    end
    
    # use path to determine folder name and
    # create the required folders if they don't exist
    def create_dirs(path)
      FileUtils.makedirs path.split('/').reverse[1..-1].reverse.join('/')
    end
    
    # copies over static content
    def copy_static
      puts " - \033[32mCopying\033[0m static content"
      static_folder = File.join(@proj_dir, @static_folder)
      FileUtils.cp_r(File.join(static_folder, '/.'), @output_folder) 
    end
    
    # create the dump dir, compile templates, copy over static assets
    def dump(production = false)
      FileUtils.mkdir(@output_folder)
      puts "\nFrank is..."
      puts " - \033[32mCreating\033[0m '#{@output_folder}'"
      
      compile_templates(production)
      copy_static
      puts "\n \033[32mCongratulations, project dumped to '#{@output_folder}' successfully!\033[0m"
    end
  end
  
end
