# encoding: utf-8

require File.expand_path('../../spec_helper.rb', __FILE__)
require 'frank/publish/scp'

describe Frank::Publish::SCP do

  let(:publisher) do
    Frank::Publish::SCP.new(Frank.publish) do |scp|
      scp.username = 'my_username'
      scp.password = 'my_password'
      scp.hostname = 'scp.example.com'
      scp.local_path = '/local/path'
      scp.remote_path = '/remote/path'
    end
  end

  before(:all) do
    Frank.bootstrap(File.join(File.dirname(__FILE__), 'template'))
  end

  describe '#initialize' do
    it 'should set the correct values' do
      publisher.username.should == 'my_username'
      publisher.password.should == 'my_password'
      publisher.hostname.should == 'scp.example.com'
      publisher.port.should == 22
      publisher.local_path.should == '/local/path'
      publisher.remote_path.should == '/remote/path'

    end

  end # describe '#initialize'

  describe '#connection' do
    let(:connection) { mock }

    it 'should yield a connection to the remote server' do
      Net::SCP.expects(:start).with('scp.example.com', 'my_username', :password => 'my_password').yields(connection)

      publisher.send(:connection) do |scp|
        scp.should be(connection)
      end
    end

  end # describe '#connection'

  describe '#transfer!' do
    let(:connection) { mock }

    before do
      publisher.stubs(:connection).yields(connection)
    end

    it 'should transfer the local_path to remote_path using upload!' do
      connection.expects(:upload!).with('/local/path', '/remote/path')

      publisher.send(:transfer!)
    end
  end # describe '#transfer!'

end
