libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

local_helpers = File.join(Dir.pwd, 'helpers.rb')
require local_helpers[0..-4] if File.exists? local_helpers

require 'rubygems'
require 'frank/base'
require 'frank/output'
