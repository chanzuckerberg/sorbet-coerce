# typed: true
require 'sorbet-runtime'

module T::Coerce
  module Configuration
    class << self
      extend T::Sig

      sig { returns(T::Boolean) }
      attr_accessor :raise_coercion_error
    end
  end
end

T::Coerce::Configuration.raise_coercion_error = true
