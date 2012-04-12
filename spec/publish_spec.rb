require File.dirname(__FILE__) + '/spec_helper'


describe Frank::Publish do
  include Rack::Test::Methods
  include Frank::Spec::Helpers

  let(:proj_dir) { File.join(File.dirname(__FILE__), 'template') }
  let(:protocols) { [:ftp, :ftptls, :sftp, :scp] }

  before(:all) do
    Frank.bootstrap(proj_dir)
  end

  describe '#exit_unless_configured' do

    before do
      Frank.publish.host = 'example.com'
      Frank.publish.username = 'test'
    end

    # How do I prohibit SystemExit from really exiting?
    #
    #it 'should exit if mandatory username param is missing' do
    #  Frank.publish.username= nil
    #
    #  lambda {
    #    Frank::Publish.exit_unless_configured
    #  }.should raise_error(SystemExit)
    #end
    #
    #it 'should exit if mandatory host param is missing' do
    #  Frank.publish.host= nil
    #
    #  lambda {
    #    Frank::Publish.exit_unless_configured
    #  }.should raise_error(SystemExit)
    #end

    it 'should return the publish protocol to use' do
      protocols.each do |p|
        Frank.publish.mode = p

        Frank::Publish.exit_unless_configured.should == p
      end

    end

  end

  describe '#execute!' do

    let(:publisher) { mock }

    it 'should instatiate and call perform! on the appropriate class' do
      protocols.each do |proto|
        Frank.publish.mode = proto

        require "frank/publish/#{proto}"

        clazz = Frank::Publish.const_get(proto.to_s.upcase)
        clazz.stubs(:new).with(Frank.publish).returns(publisher)
        publisher.expects(:perform!)

        Frank::Publish.execute!

      end

    end
  end


end
