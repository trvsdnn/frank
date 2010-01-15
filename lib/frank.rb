libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require File.join(Dir.pwd, 'helpers')
require 'rubygems'
require 'frank/base'
require 'frank/output'
