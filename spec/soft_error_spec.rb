# typed: false
require 'sorbet-coerce'
require 'sorbet-runtime'

describe T::Coerce do
  context 'when type errors are soft errors' do
    let(:ignore_error) { Proc.new {} }

    before(:each) do
      allow(T::Configuration).to receive(
        :inline_type_error_handler,
      ).and_return(ignore_error)

      allow(T::Configuration).to receive(
        :call_validation_error_handler,
      ).and_return(ignore_error)

      allow(T::Configuration).to receive(
        :sig_builder_error_handler,
      ).and_return(ignore_error)
    end

    class ParamsWithSortError < T::Struct
      const :a, Integer
    end

    class CustomTypeRaisesHardError
      def initialize(value)
        raise StandardError.new('value cannot be 1') if value == 1
      end
    end

    class CustomTypeDoesNotRiaseHardError
      def self.new(a); 1; end
    end

    it 'works as expected' do
      invalid_arg = 'invalid integer string'
      expect(T::Coerce[Integer].new.from(invalid_arg)).to eql(invalid_arg)
      expect(T::Coerce[T::Array[Integer]].new.from(1)).to be 1
      expect(T::Coerce[T::Array[Integer]].new.from(invalid_arg)).to eql(invalid_arg)
      expect(T::Coerce[T::Array[Integer]].new.from({a: 1})).to eql([[:a, 1]])

      expect {
        T::Coerce[CustomTypeRaisesHardError].new.from(1)
      }.to raise_error(StandardError)
      expect(T::Coerce[CustomTypeDoesNotRiaseHardError].new.from(1)).to eql(1)

      sorbet_version = Gem.loaded_specs['sorbet-runtime'].version
      if sorbet_version >= Gem::Version.new('0.4.4948') && sorbet_version < Gem::Version.new('0.5.0')
        expect(T::Coerce[ParamsWithSortError].new.from({a: invalid_arg}).a).to eql(invalid_arg)
      end
    end
  end
end
