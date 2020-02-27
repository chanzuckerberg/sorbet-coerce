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

`T::Coerce` takes a valid sorbet type and coerce the input value into that type. It'll return a statically-typed object or throws errors when the coercion process cannot be handled as expected (more details in the [Errors](#errors) section).
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
- `T::Hash[<supported type>, <supported type>]`
- Subclasses of `T::Struct`

We don't support
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
T::Coerce[T.nilable(Integer)].new.from(nil)
# => nil
T::Coerce[T.nilable(Integer)].new.from('')
# => nil
```
But, `''` will be converted to an empty string for `T.nilable(String)` type
```ruby
T::Coerce[T.nilable(String)].new.from('')
# => ""
```

- `T::Array`

```ruby
T::Coerce[T::Array[Integer]].new.from([1.0, '2.0'])
# => [1, 2]
```

- `T::Struct`

```ruby
class Params < T::Struct
  const :id, Integer
  const :role, String, default: 'wizard'
end

T::Coerce[Params].new.from({id: '1'})
# => <Params id=1, role="wizard">
```
More examples: [nested params](https://github.com/chanzuckerberg/sorbet-coerce/blob/a56c0c6a363bb49b11e77ac57893afc3d54c6b8c/spec/nested_spec.rb#L18-L26)

## Errors
We will get `CoercionError`, `ShapeError`, or `TypeError` when the coercion doesn't work successfully.

#### `T::Coerce::CoercionError` (configurable)
It raises a coercion error when it fails to convert a value into the specified type (i.e. `'bad string args' to Integer`). This can be configured globally or at each call-site. When configured to `true`, it will fill the result with `nil` instead of raising the errors.
```ruby
T::Coerce::Configuration.raise_coercion_error = false # default to true
```
We can use an inline flag to overwrite the global configuration:
```ruby
T::Coerce[T.nilable(Integer)].new.from('abc', raise_coercion_error: false)
# => nil
```

#### `T::Coerce::ShapeError` (NOT configurable)
It raises a shape error when the shape of the input does not match the shape of input type (i.e. `'1' to T::Array[Integer]` or to `T::Struct`). This cannot be configured and always raise an error.

#### `TypeError` (configurable)
It raises a type error when the coerced input does not match the input type. This error is raised by Sorbet and can be configured through [`T::Configuration`](https://sorbet.org/docs/tconfiguration).


#### Soft Errors vs. Hard Errors
In an environment where type errors and coercion errors are configured to be silent (referred to as soft errors), when the coercion fails, `T::Coerce` will fill the result with `nil` instead of actually raising the errors (referred to hard errors).

With hard errors,
```ruby
class Params < T::Struct
  const :a, Integer
end

T::Coerce[Integer].new.from(nil)
# => TypeError Exception: T.let: Expected type Integer, got type NilClass

T::Coerce[Integer].new.from('abc')
# => T::Coerce::CoercionError Exception: Could not coerce value ("abc") of type (String) to desired type (Integer)

T::Coerce[T.nilable(Integer)].new.from('abc', raise_coercion_error: false)
# => nil

T::Coerce[Params].new.from({a: 'abc'}, raise_coercion_error: false)
# => TypeError Exception: Parameter 'a': Can't set Params.a to nil (instance of NilClass) - need a Integer
```

With soft errors,
```ruby
T::Coerce[Integer].new.from('abc', raise_coercion_error: false)
# => nil

T::Coerce[Params].new.from({a: 'abc'}, raise_coercion_error: false) # require sorbet version ~> 0.4.4948
# => <Params a=nil>

T::Coerce[Params].new.from({a: 'abc'}, raise_coercion_error: true)
# T::Coerce::CoercionError Exception: Could not coerce value ("abc") of type (String) to desired type (Integer)
```

## `null`, `''`, and `undefined`

Sorbet-coerce is designed in the context of web development. When coercing into a `T::Struct`, the values that need to be coerced are often JSON-like. Suppose we send a JavaScript object
```javascript
json_js = {"a": "1", "null_field": null, "blank_field": "", "missing_key": undefined} // javascript
```
to the server side and get a JSON hash
```ruby
json_rb = {"a" => "1", "null_field" => nil, "blank_field" => ""} # ruby, note `missing_key` is removed from the hash
```
We expect the object to have shape
```ruby
class Params < T::Struct
  const :a, Integer
  const :null_field, T.nilable(Integer)
  const :blank_field, T.nilable(Integer)
  const :missing_key, T::Array[Integer], default: []
end
```

Then we coerce the object `json_rb` into an instance of `Params`.
```ruby
params = T::Coerce[Params].new.from(json_rb)
# => <Params a=1, blank_field=nil, missing_key=[], null_field=nil>
```
- When `json_js["null_field"]` is `null`, `params.null_field` is `nil`
- When `json_js["blank_field"]` is `""`, `params.blank_field` is `nil`
- When `json_js["missing_key"]` is `undefined`, `params.missing_key` will use the default value `[]`

## Contributing

Contributions and ideas are welcome! Please see [our contributing guide](CONTRIBUTING.md) and don't hesitate to open an issue or send a pull request to improve the functionality of this gem.

This project adheres to the Contributor Covenant [code of conduct](https://github.com/chanzuckerberg/.github/tree/master/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to opensource@chanzuckerberg.com.

## License

This project is licensed under [MIT](https://github.com/chanzuckerberg/sorbet-coerce/blob/master/LICENSE).
