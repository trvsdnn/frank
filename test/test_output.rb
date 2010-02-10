require File.dirname(__FILE__) + '/helper'

class TestBase < Test::Unit::TestCase

  context 'Frank::Base' do
    
    setup do
      settings = YAML.load_file('template/settings.yml')
      @frank = Frank::Output.new do
        settings.each do |name, value|
          set name.to_s, value
        end
        set :environment, :test
        set :proj_dir, File.join(Dir.pwd, 'template')
        set :output_folder, 'output'
      end.dump
    end
    
    should 'create the output folder' do
      assert File.exist? 'template/output'
    end
    
    teardown do
      FileUtils.rm_r File.join(Dir.pwd, 'template/output')
    end

    
  end
  
end