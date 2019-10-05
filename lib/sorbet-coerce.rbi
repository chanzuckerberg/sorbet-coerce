# typed: strict

module T
  module Coerce
    extend T::Sig
    extend T::Generic

    Elem = type_member

    sig { params(args: T.untyped).returns(Elem) }
    def from(args); end
  end
end
