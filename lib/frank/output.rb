require 'find'

module Frank
  class Output < Frank::Base
    include Frank::Render
    
    attr_accessor :static_folder, :dynamic_folder, :templates, :output_folder, :proj_dir
    
    def initialize(&block)
      instance_eval &block
      @output_path = File.join(@proj_dir, @output_folder)
    end
        
    def compile_templates
      dir = File.join( @proj_dir, @dynamic_folder )
      
      Find.find(dir) do |path|
        if FileTest.file?(path) and !File.basename(path).match(/^\./)
          path = path[ dir.size + 1 ..-1 ]
          name, ext = name_ext(path)
          new_ext = reverse_ext_lookup(ext)
          new_file = File.join( @output_folder,  "#{name}.#{new_ext}")          
          FileUtils.makedirs(new_file.split('/').reverse[1..-1].reverse.join('/'))
          
          File.open(new_file, 'w') {|f| f.write render_path(path) }
          puts "Create #{name}.#{new_ext}"
        end
      end
    end
  
    def copy_static
      puts "Copying over your static content"
      static_folder = File.join(@proj_dir, @static_folder)
      FileUtils.cp_r(File.join(static_folder, '/.'), @output_path) 
    end
  
    def dump
      FileUtils.mkdir(@output_path)
      puts "Create #{@output_folder}"
      
      compile_templates
      copy_static
    end
  end
  
end