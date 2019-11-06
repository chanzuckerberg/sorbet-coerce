# sorbet-coerce
[![Gem Version](https://badge.fury.io/rb/sorbet-coerce.svg)](https://badge.fury.io/rb/sorbet-coerce)
[![Build Status](https://travis-ci.com/chanzuckerberg/sorbet-coerce.svg?branch=master)](https://travis-ci.com/chanzuckerberg/sorbet-coerce)
[![codecov](https://codecov.io/gh/chanzuckerberg/sorbet-coerce/branch/master/graph/badge.svg)](https://codecov.io/gh/chanzuckerberg/sorbet-coerce)

A type coercion lib works with [Sorbet](https://sorbet.org)'s static type checker and type definitions; raises an error if the coercion fails.

It provides a simple and generic way of coercing types in a sorbet-typed project. It is particularly useful when we're dealing with external API responses and controller parameters.

## Installation
1. Follow the steps [here](https://sorbet.org/docs/adopting) to set up the latest version of Sorbet and run `srb tc`.
2. Add `sorbet-coerce` to your Gemfile and install them with `Bundler`.
```
# -- Gemfile --

gem 'sorbet-coerce'
```

```sh
❯ bundle install
```

## Usage

`T::Coerce` takes a valid sorbet type and coerce the input value into that type. It'll return a statically-typed object or throws `T::CoercionError` error if the coercion fails.
```ruby
converted = T::Coerce[<Type>].new.from(<value>)

T.reveal_type(converted) # <Type>
```

### Supported Types
- Simple Types
- Custom Types: If the values can be coerced by `.new`
- `T::Boolean`
- `T.nilable(<supported type>)`
- `T::Array[<supported type>]`
- Subclasses of `T::Struct`

We don't support
- `T::Hash` (currently)
- `T::Enum` (currently)
- Experimental features (tuples and shapes)
- `T.any(<supported type>, ...)`: A union type other than `T.nilable`

### Examples
- Simple Types

```ruby
T::Coerce[T::Boolean].new.from('false')
# => false

T::Coerce[T::Boolean].new.from('true')
# => true

T::Coerce[Date].new.from('2019-08-05')
# => #<Date: 2019-08-05 ((2458701j,0s,0n),+0s,2299161j)>

T::Coerce[DateTime].new.from('2019-08-05')
# => #<DateTime: 2019-08-05T00:00:00+00:00 ((2458701j,0s,0n),+0s,2299161j)>

T::Coerce[Float].new.from('1')
# => 1.0

T::Coerce[Integer].new.from('1')
# => 1

T::Coerce[String].new.from(1)
# => "1"

T::Coerce[Symbol].new.from('a')
# => :a

T::Coerce[Time].new.from('2019-08-05')
# => 2019-08-05 00:00:00 -0700
```

- `T.nilable`

```ruby
T::Coerce[T.nilable(Integer)].new.from('')
# => nil
```

- `T::Array`

```ruby
T::Coerce[T::Array[Integer]].new.from([1.0, '2.0'])
# => [1, 2]
```

- `T::Struct`

```ruby
class Param < T::Struct
  const :id, Integer
  const :role, String, default: 'wizard'
end

T::Coerce[Param].new.from({id: '1'})
# => <Param id=1, role="wizard">
```
More examples: [nested params](https://github.com/chanzuckerberg/sorbet-coerce/blob/a56c0c6a363bb49b11e77ac57893afc3d54c6b8c/spec/nested_spec.rb#L18-L26)

## Coercion Error

Sorbet-coerce throws a coercion error when it fails to convert a value into the specified type. The error is [configurable](https://sorbet.org/docs/runtime#changing-the-runtime-behavior) through `T::Configuration`. In an environment where type errors are configured to be silent (referred to soft errors), when the coercion fails (or constructing `T::Struct` fails), `T::Coerce` will return the original value instead of actually raising the errors (referred to hard errors).

## `null`, `''`, and `undefined`

Sorbet-coerce is designed in the context of web development. When coercing into a `T::Struct`, the values that need to be coerced are often JSON-like. Suppose we're coercing object `json` into a `Param` instance
```ruby
json = {"a": "1", "null_filed": null, "blank_filed": ""}

class Params < T::Struct
  const :a, Integer
  const :null_filed, T.nilable(Integer)
  const :blank_filed, T.nilable(Integer)
  const :missing_key, T::Array[Integer], default: []
end

param = T::Coerce[Params].new.from(json)
```

- When `json["null_filed"]` is `null`, `param.null_filed` is `nil`
- When `json["blank_filed"]` is `""`, `param.blank_filed` is `nil`
- When `json["missing_key"]` is `undefined`, `param.missing_key` will use the default value `[]`

## Contributing

Contributions and ideas are welcome! Please see [our contributing guide](CONTRIBUTING.md) and don't hesitate to open an issue or send a pull request to improve the functionality of this gem.

This project adheres to the Contributor Covenant [code of conduct](https://github.com/chanzuckerberg/.github/tree/master/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to opensource@chanzuckerberg.com.

## License

This project is licensed under [MIT](https://github.com/chanzuckerberg/sorbet-coerce/blob/master/LICENSE).
