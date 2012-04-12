# encoding: utf-8

require File.expand_path('../../spec_helper.rb', __FILE__)
require 'frank/publish/base'


describe Frank::Publish::Base do

  let(:publisher) do
    Frank::Publish::Base.new(Frank.publish)
  end

  before(:all) do
    Frank.bootstrap(File.join(File.dirname(__FILE__), '..', 'template'))
  end

  describe '#initialize' do

    it 'should set the correct values' do
      publisher.username.should == 'test'
      publisher.password.should == 'secret'
      publisher.hostname.should == 'example.com'
      publisher.remote_path.should == '/remote/path'
    end

    it 'should set the local export path' do
      publisher.local_path =~ /\/tmp\/frank-publish-template-\d+\//
    end

  end

  describe '#permform!' do

    before do
      publisher.stubs(:export!)
      publisher.stubs(:transfer!)
      publisher.stubs(:cleanup!)
    end

    it 'call export, transfer, cleanup ins that order' do
      publisher.expects(:export!)
      publisher.expects(:transfer!)
      publisher.expects(:cleanup!)

      publisher.perform!
    end

  end

  describe '#files_to_transfer' do

    it 'should list empty directories if export does not exists' do
      publisher.send(:files_to_transfer).should be_empty
    end

    it 'should list all files' do
      publisher.send(:export!)
      publisher.send(:files_to_transfer).should have(26).elements
      publisher.send(:files_to_transfer).should include("500.html")
      publisher.send(:files_to_transfer).should_not include("files")
    end

    it 'should not list hidden files beginning with .' do
      publisher.send(:export!)
      publisher.send(:files_to_transfer).each do |elem|
        elem.should_not =~ /^\./
      end
    end

    after do
      publisher.send(:cleanup!)
    end

  end

  describe '#directories' do

    it 'should list empty directories if export does not exists' do
      publisher.send(:directories).should be_empty
    end

    it 'should list all directories' do
      publisher.send(:export!)
      publisher.send(:directories).should include("files", "nested", "nested/deeper", "stylesheets")
    end

    it 'should not list . or ..' do
      publisher.send(:export!)
      publisher.send(:directories).should_not include('.', '..')
    end

    after do
      publisher.send(:cleanup!)
    end

  end

  describe '#export!' do

    it 'should export the project to the tmp folder' do
      publisher.send(:export!)

      publisher.local_path.should =~ /\/tmp\/frank-publish-template-\d+/
      File.exist?(publisher.local_path).should be_true
    end

    after do
      publisher.send(:cleanup!)
    end

  end

  describe '#cleanup!' do

    it 'should not leave the export folder in the tmp folder' do
      publisher.send(:export!)
      publisher.send(:cleanup!)

      publisher.local_path.should =~ /\/tmp\/frank-publish-template-\d+/
      File.exist?(publisher.local_path).should_not be_true
    end

  end

end
