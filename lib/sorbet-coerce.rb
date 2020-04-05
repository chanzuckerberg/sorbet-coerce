# typed: strict
require 'sorbet-coerce/configuration'
require 'sorbet-coerce/converter'
require 'safe_type'

module TypeCoerce
  class CoercionError < SafeType::CoercionError; end
  class ShapeError < SafeType::CoercionError; end

  define_singleton_method(:[]) do |type|
    Class.new(TypeCoerce::Private::Converter) do
      define_method(:to_s) { "#{name}#[#{type.to_s}]" }

      define_method(:from) do |args, raise_coercion_error: nil|
        if raise_coercion_error.nil?
          raise_coercion_error = TypeCoerce::Configuration.raise_coercion_error
        end

        T.send('let', send('_convert', args, type, raise_coercion_error), type)
      end
    end
  end
end
