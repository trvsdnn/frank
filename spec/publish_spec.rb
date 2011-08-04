require File.dirname(__FILE__) + '/helper'

describe Frank::Publish do
  include Rack::Test::Methods
  include Frank::Spec::Helpers

    let(:proj_dir) { File.join(File.dirname(__FILE__), 'template') }

    before :all do
      Dir.chdir proj_dir do
        frank 'publish'
      end
    end

    it 'creates the published folder' do
      File.exist?("/tmp/frankexp-#{proj_dir.split('/').last}").should be_true
    end

    after(:all) do
      #FileUtils.rm_r File.join(File.dirname(__FILE__), 'template/output')
    end

end
