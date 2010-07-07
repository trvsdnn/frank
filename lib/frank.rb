LIBDIR = File.dirname(__FILE__)

local_helpers = File.join(Dir.pwd, 'helpers.rb')
require local_helpers[0..-4] if File.exists? local_helpers

module Frank
  class TemplateError < StandardError; end
  class ConfigError < StandardError; end
end

require 'rubygems'
require 'yaml'
require 'fileutils'
require 'rack'
require 'frank/base'
require 'frank/output'
