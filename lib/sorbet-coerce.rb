# typed: ignore
require 'sorbet-coerce/configuration'
require 'sorbet-coerce/converter'
require 'safe_type'

module TypeCoerce
  class CoercionError < SafeType::CoercionError; end
  class ShapeError < SafeType::CoercionError; end

  def self.[](type)
    Converter.new(type)
  end

  class Converter
    include TypeCoerce::Private::Converter

    def initialize(type)
      @type = type
    end

    def new
      self
    end

    def to_s
      "#{name}#[#{@type.to_s}]"
    end

    def from(args, raise_coercion_error: nil)
      if raise_coercion_error.nil?
        raise_coercion_error = TypeCoerce::Configuration.raise_coercion_error
      end

      T.let(_convert(args, @type, raise_coercion_error), @type)
    end
  end
end
