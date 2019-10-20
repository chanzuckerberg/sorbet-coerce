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
T::Coerce[Integer].new.from('invalid number')
# => T::CoercionError (Could not coerce value ("invalid number") of type (String) to desired type (Integer))

T::Coerce[T.nilable(Integer)].new.from('invalid number')
# => nil
```

- `T::Array`

```ruby
T::Coerce[T::Array[Integer]].new.from([1.0, '2.0'])
# => [1, 2]

T::Coerce[T::Array[Integer]].new.from([1.0, 'invalid num'])
# => []

T::Coerce[T::Array[T.nilable(Integer)]].new.from([1.0, 'invalid num'])
# => [1, nil]
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

## Contributing

Contributions and ideas are welcome! Please see [our contributing guide](CONTRIBUTING.md) and don't hesitate to open an issue or send a pull request to improve the functionality of this gem.

This project adheres to the Contributor Covenant [code of conduct](https://github.com/chanzuckerberg/.github/tree/master/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to opensource@chanzuckerberg.com.

## License

This project is licensed under [MIT](https://github.com/chanzuckerberg/sorbet-coerce/blob/master/LICENSE).
