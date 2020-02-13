# typed: true
module T
  module Coerce
    extend T::Sig
    extend T::Generic

    Elem = type_member

    sig { params(args: T.untyped, raise_value_error: T.nilable(T::Boolean)).returns(Elem) }
    def from(args, raise_value_error: nil); end
  end

  module Private
    module Types
      class TypeAlias
        def aliased_type; end
      end
    end
  end
end
