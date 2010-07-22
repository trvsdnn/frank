require 'tilt'

module Frank

  # add Frank.sass_options to be configured
  @@sass_options = nil unless defined?(@@sass_options)
  def self.sass_options
    @@sass_options
  end
  def self.sass_options=(obj)
    @@sass_options = obj
  end

  # Scss template implementation. See:
  # http://haml.hamptoncatlin.com/
  #
  # Sass templates do not support object scopes, locals, or yield.
  class SassTemplate < Tilt::SassTemplate
    def prepare
      @engine = ::Sass::Engine.new(data, sass_options.merge(Frank.sass_options).merge(:syntax => :sass))
    end
  end
  Tilt.register 'sass', SassTemplate

  # Scss template implementation. See:
  # http://haml.hamptoncatlin.com/
  #
  # Sass templates do not support object scopes, locals, or yield.
  class ScssTemplate < Tilt::SassTemplate
    def prepare
      @engine = ::Sass::Engine.new(data, sass_options.merge(Frank.sass_options).merge(:syntax => :scss))
    end
  end
  Tilt.register 'scss', ScssTemplate

  # Radius Template
  # http://github.com/jlong/radius/
  class RadiusTemplate < Tilt::Template
    def initialize_engine
      return if defined? ::Radius
      require_template_library 'radius'
    end

    def prepare
      @context = Class.new(Radius::Context).new
    end

    def evaluate(scope, locals, &block)
      @context.define_tag("yield") do
        block.call
      end
      (class << @context; self; end).class_eval do
        define_method :tag_missing do |tag, attr, &block|
          if locals.key?(tag.to_sym)
            locals[tag.to_sym]
          else
            scope.__send__(tag)  # any way to support attr as args?
          end
        end
      end
      # TODO: how to config tag prefix?
      parser = Radius::Parser.new(@context, :tag_prefix => 'r')
      parser.parse(data)
    end
  end
  Tilt.register 'radius', RadiusTemplate
end