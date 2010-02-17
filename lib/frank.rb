LIBDIR = File.dirname(__FILE__)
$LOAD_PATH.unshift(LIBDIR) unless $LOAD_PATH.include?(LIBDIR)

local_helpers = File.join(Dir.pwd, 'helpers.rb')
require local_helpers[0..-4] if File.exists? local_helpers

require 'rubygems'
require 'frank/base'
require 'frank/output'
