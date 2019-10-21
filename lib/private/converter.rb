# typed: strict
require 'safe_type'
require 'sorbet-runtime'
require 'polyfill'

using Polyfill(Hash: %w[#slice])

module T; end

module T::Private
  class Converter
    extend T::Sig

    PRIMITIVE_TYPES = T.let(::Set[
      Date,
      DateTime,
      Float,
      Integer,
      String,
      Symbol,
      Time,
    ], T.untyped)

    protected
    sig { params(value: T.untyped, type: T.untyped).returns(T.untyped) }
    def _convert(value, type)
      if type.is_a?(T::Types::TypedArray)
        _convert_to_a(value, type.type)
      elsif type.is_a?(T::Types::Simple)
        _convert(value, type.raw_type)
      elsif type.is_a?(T::Types::Union)
        true_idx = T.let(nil, T.nilable(Integer))
        false_idx = T.let(nil, T.nilable(Integer))
        nil_idx = T.let(nil, T.nilable(Integer))

        type.types.each_with_index do |t, i|
          nil_idx = i if t.is_a?(T::Types::Simple) && t.raw_type == NilClass
          true_idx = i if t.is_a?(T::Types::Simple) && t.raw_type == TrueClass
          false_idx = i if t.is_a?(T::Types::Simple) && t.raw_type == FalseClass
        end

        raise ArgumentError.new(
          'the only supported union types are T.nilable and T::Boolean',
        ) unless type.types.length == 2 && (
          !nil_idx.nil? || (!true_idx.nil? && !false_idx.nil?)
        )

        if nil_idx.nil?
          # Must be T::Boolean
          _convert_simple(value, type)
        else
          _convert(value, type.types[nil_idx == 0 ? 1 : 0])
        end
      elsif type < T::Struct
        args = _build_args(value, type.props)
        begin
          type.new(args)
        rescue T::Props::InvalidValueError, ArgumentError
          nil
        end
      else
        _convert_simple(value, type)
      end
    end

    sig { params(value: T.untyped, type: T.untyped).returns(T.untyped) }
    def _convert_simple(value, type)
      return nil if value.nil?
      safe_type_rule = T.let(nil, T.untyped)

      if type == T::Boolean
        safe_type_rule = SafeType::Boolean.strict
      elsif value.is_a?(type)
        return value
      elsif PRIMITIVE_TYPES.include?(type)
        safe_type_rule = SafeType.const_get(type.name).strict
      else
        safe_type_rule = type
      end
      SafeType::coerce(value, safe_type_rule)
    rescue SafeType::EmptyValueError, SafeType::CoercionError
      nil
    rescue SafeType::InvalidRuleError
      begin
        type.new(value)
      rescue
        nil
      end
    end

    sig { params(ary: T.untyped, type: T.untyped).returns(T.untyped) }
    def _convert_to_a(ary, type)
      ary = [ary] unless ary.is_a?(::Array)
      T.send(
        'let',
        ary.map { |value| _convert(value, type) },
        T.const_get('Array')[type],
      )
    rescue TypeError
      []
    end

    sig { params(args: T.untyped, props: T.untyped).returns(T.untyped) }
    def _build_args(args, props)
      return {} if args.nil?
      args.map { |name, value|
        key = name.to_sym
        [
          key,
          (!props.include?(key) || value.nil?) ?
            nil : _convert(value, props[key][:type]),
        ]
      }.to_h.slice(*props.keys)
    end
  end
end
