# typed: strict
require 'private/converter'
require 'safe_type'

module T
  class CoercionError < SafeType::CoercionError; end

  module Coerce
    define_singleton_method(:[]) do |type|
      Class.new(T::Private::Converter) do
        define_method(:to_s) { "#{name}#[#{type.to_s}]" }

        define_method(:from) do |args|
          T.send('let', send('_convert', args, type), type)
        rescue TypeError
          raise CoercionError.new(args, type)
        end
      end
    end
  end
end
