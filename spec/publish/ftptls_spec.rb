# encoding: utf-8

require File.expand_path('../../spec_helper.rb', __FILE__)
require 'frank/publish/ftptls'

describe Frank::Publish::FTPTLS do

  let(:publisher) do
    Frank::Publish::FTPTLS.new(Frank.publish) do |ftp|
      ftp.username = 'my_username'
      ftp.password = 'my_password'
      ftp.hostname = 'ftp.example.com'
      ftp.local_path = '/local/path'
      ftp.remote_path = '/remote/path'
    end
  end

  before(:all) do
    Frank.bootstrap(File.join(File.dirname(__FILE__), 'template'))
  end

  describe '#initialize' do
    it 'should set the correct values' do
      publisher.username.should == 'my_username'
      publisher.password.should == 'my_password'
      publisher.hostname.should == 'ftp.example.com'
      publisher.port.should == 21
      publisher.local_path.should == '/local/path'
      publisher.remote_path.should == 'remote/path'

    end

    it 'should remove any preceeding tilde and slash from the path' do
      publisher = Frank::Publish::FTPTLS.new(Frank.publish) do |ftp|
        ftp.remote_path = '~/my_backups/path'
      end
      publisher.remote_path.should == 'my_backups/path'
    end

    context 'when setting configuration defaults' do


    end # context 'when setting configuration defaults'

  end # describe '#initialize'

  describe '#connection' do
    let(:connection) { mock }

    it 'should yield a connection to the remote server' do
      Net::FTPTLS.expects(:open).with(
        'ftp.example.com', 'my_username', 'my_password'
      ).yields(connection)

      connection.expects(:passive=).with(true)

      publisher.send(:connection) do |ftp|
        ftp.should be(connection)
      end
    end

    it 'should set the Net::FTP_PORT constant' do
      publisher.port = 40
      Net::FTPTLS.expects(:const_defined?).with(:FTP_PORT).returns(true)
      Net::FTPTLS.expects(:send).with(:remove_const, :FTP_PORT)
      Net::FTPTLS.expects(:send).with(:const_set, :FTP_PORT, 40)

      Net::FTPTLS.expects(:open)
      publisher.send(:connection)
    end

  end # describe '#connection'

  describe '#transfer!' do
    let(:connection) { mock }
    let(:package) { mock }
    let(:files) { ["file1", "file2", "subdir1/file3", "subdir2/file4"] }
    let(:dirs) { ["subdir1", "subdir2"] }
    let(:s) { sequence '' }

    before do
      publisher.stubs(:connection).yields(connection)
      publisher.stubs(:files_to_transfer).returns(files)
      publisher.stubs(:directories).returns(dirs)
    end

    it 'should transfer the files' do


      # connection.expects(:chdir).in_sequence(s).with('remote/path')

      #publisher.expects(:directories).in_sequence(s)

      publisher.expects(:create_remote_path).in_sequence(s).with('remote/path/subdir1', connection)
      publisher.expects(:create_remote_path).in_sequence(s).with('remote/path/subdir2', connection)

      connection.expects(:put).in_sequence(s).with(
        File.join('/local/path', 'file1'),
        File.join('remote/path', 'file1')
      )

      connection.expects(:put).in_sequence(s).with(
        File.join('/local/path', 'file2'),
        File.join('remote/path', 'file2')
      )

      connection.expects(:put).in_sequence(s).with(
        File.join('/local/path', 'subdir1/file3'),
        File.join('remote/path', 'subdir1/file3')
      )

      connection.expects(:put).in_sequence(s).with(
        File.join('/local/path', 'subdir2/file4'),
        File.join('remote/path', 'subdir2/file4')
      )

      publisher.send(:transfer!)
    end
  end # describe '#transfer!'


  describe '#create_remote_path' do
    let(:connection) { mock }
    let(:remote_path) { 'remote/folder/another_folder' }
    let(:s) { sequence '' }

    context 'while properly creating remote directories one by one' do
      it 'should rescue any FTPPermErrors and continue' do
        connection.expects(:mkdir).in_sequence(s).
          with("remote").raises(Net::FTPPermError)
        connection.expects(:mkdir).in_sequence(s).
          with("remote/folder")
        connection.expects(:mkdir).in_sequence(s).
          with("remote/folder/another_folder")

        expect do
          publisher.send(:create_remote_path, remote_path, connection)
        end.not_to raise_error
      end
    end
  end

end
