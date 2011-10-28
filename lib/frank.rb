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
require 'frank/settings'
require 'frank/base'
require 'frank/compile'
require 'frank/publish'
require 'frank/cli'

# relay
module Frank

  # Quickly configure Frank settings. Best used by passing a block.
  #
  # Example:
  #
  #   Frank.configure do |settings|
  #     settings.server.hostname = "0.0.0.0"
  #     settings.server.port = "3601"
  #
  #     settings.site_folder = "site"
  #     settings.layouts_folder = "layouts"
  #   end
  #
  # Returns:
  #
  # The Frank +Settings+ singleton instance.
  class << self
    def configure
      settings = Frank::Settings.instance
      block_given? ? yield(settings) : settings
    end
  end

  # Take all the public instance methods from the Settings singleton and allow
  # them to be accessed through the Frank module directly.
  #
  # Examples:
  #
  # <tt>Frank.server.hander #=> "mongrel"</tt>
  # <tt>Frank.static_folder #=> "static"</tt>
  Frank::Settings.public_instance_methods(false).each do |name|
    define_method name.to_sym do
      configure.send(name, *args)
    end
  end
end