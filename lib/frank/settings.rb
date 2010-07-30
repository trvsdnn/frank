require 'singleton'
require 'ostruct'
module Frank
  class Settings
    include Singleton

    attr_accessor :environment
    attr_accessor :root

    attr_accessor :server
    attr_accessor :static_folder
    attr_accessor :dynamic_folder
    attr_accessor :layouts_folder
    attr_accessor :sass_options

    def initialize
      reset
    end

    # Reset settings to the defaults
    def reset
      # reset server settings
      @server = OpenStruct.new
      @server.handler = "mongrel"
      @server.hostname = "0.0.0.0"
      @server.port = "3601"

      # setup folders
      @static_folder = "static"
      @dynamic_folder = "dynamic"
      @layouts_folder = "layouts"

      # setup 3rd party configurations
      @sass_options = {}
    end

  end
end