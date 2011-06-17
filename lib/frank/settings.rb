require 'singleton'
require 'ostruct'
module Frank
  class Settings
    include Singleton

    attr_accessor :environment
    attr_accessor :root

    attr_accessor :server
    attr_accessor :options
    attr_accessor :static_folder
    attr_accessor :dynamic_folder
    attr_accessor :layouts_folder
    attr_accessor :export
    attr_accessor :publish
    attr_accessor :sass_options
    attr_accessor :haml_options

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

      # reset options
      @options = OpenStruct.new

      # export settings
      @export = OpenStruct.new
      @export.path = "exported"
      @export.silent = false

      # publish options
      @publish = OpenStruct.new
      @publish.host = nil
      @publish.path = nil
      @publish.username = nil
      @publish.password = nil

      # setup folders
      @static_folder = "static"
      @dynamic_folder = "dynamic"
      @layouts_folder = "layouts"

      # setup 3rd party configurations
      @sass_options = {}
      @haml_options = {}
    end

    # return the proj folder name
    def proj_name
      @root.split('/').last
    end

    # Are we serving up a raw static folder?
    def serving_static?
      @serving_static
    end

    # Mark this Frank run as serving static
    def serving_static!
      @serving_static = true
    end

    # Check to see if we're compiling
    def exporting?
      @exporting
    end

    # Mark this Frank run as compiling
    def exporting!
      @exporting = true
    end

    # Silent export if set or in test
    def silent_export?
      @environment == :test || @export.silent
    end

    # Check to see if we're in production mode
    def production?
      @production
    end

    # Mark this Frank run as production
    def production!
      @production = true
    end

    # Mark this Frank run as publishing
    def publishing!
      @exporting  = true
      @production = true
    end

  end
end
