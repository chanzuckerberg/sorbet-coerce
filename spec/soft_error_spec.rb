# typed: false
require 'sorbet-coerce'
require 'sorbet-runtime'

describe T::Coerce do
  context 'when type errors are soft errors' do
    before(:all) do
      ignore_error = Proc.new {}
      T::Configuration.inline_type_error_handler = ignore_error
      T::Configuration.call_validation_error_handler = ignore_error
      T::Configuration.sig_builder_error_handler = ignore_error
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
      expect {
        T::Coerce[CustomTypeRaisesHardError].new.from(1)
      }.to raise_error(StandardError)
      expect(T::Coerce[CustomTypeDoesNotRiaseHardError].new.from(1)).to eql(1)
    end
  end
end
