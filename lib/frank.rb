libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'
# require File.join(Dir.pwd, 'helpers') #TODO FIGURE THIS OUT
require 'frank/base'
require 'frank/output'
