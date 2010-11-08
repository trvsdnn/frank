require File.dirname(__FILE__) + '/helper'

describe Frank::Publish do
  include Rack::Test::Methods

    before :all do
      @proj_dir   = File.join(File.dirname(__FILE__), 'template')

      bin_dir    = File.join(File.dirname(File.dirname(__FILE__)), 'bin')
      Dir.chdir @proj_dir do
        system "#{bin_dir}/frank publish"
      end
    end

    it 'creates the published folder' do
      File.exist?("/tmp/frankexp-#{@proj_dir.split('/').last}").should be_true
    end

    after(:all) do
      #FileUtils.rm_r File.join(File.dirname(__FILE__), 'template/output')
    end

end
