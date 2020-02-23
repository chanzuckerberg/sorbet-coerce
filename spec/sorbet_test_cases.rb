# typed: true
require 'sorbet-coerce'

T.assert_type!(T::Coerce[Integer].new.from('1'), Integer)
T.assert_type!(
  T::Coerce[T.nilable(Integer)].new.from('invalid', raise_coercion_error: false),
  T.nilable(Integer),
)

T::Coerce::Configuration.raise_coercion_error = true
coercion_error = nil
begin
  T::Coerce[T.nilable(Integer)].new.from('invalid')
rescue T::Coerce::CoercionError => e
  coercion_error = e
end
raise 'no coercion error is raised' unless coercion_error

T.assert_type!(
  T::Coerce[T.nilable(Integer)].new.from('invalid', raise_coercion_error: false),
  T.nilable(Integer),
)
