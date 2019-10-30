# typed: false
require 'sorbet-coerce'
require 'sorbet-runtime'

describe T::Coerce do
  context 'when given nested types' do
    class User < T::Struct
      const :id, Integer
      const :valid, T.nilable(T::Boolean)
    end

    class NestedParam < T::Struct
      const :users, T::Array[User]
      const :params, T.nilable(NestedParam)
    end

    it 'works with nest T::Struct' do
      converted = T::Coerce[NestedParam].new.from({
        users: {id: '1'},
        params: {
          users: {id: '2', valid: 'true'},
          params: {
            users: {id: '3', valid: 'true'},
          },
        },
      })
      # => <NestedParam
      #   params=<NestedParam
      #     params=<NestedParam
      #       params=nil,
      #       users=[<User id=3 valid=true>]
      #     >,
      #     users=[<User id=2 valid=true>]
      #   >,
      #   users=[<User id=1 valid=nil>]
      # >

      expect(converted.users.map(&:id)).to eql([1])
      expect(converted.params.users.map(&:id)).to eql([2])
      expect(converted.params.params.users.map(&:id)).to eql([3])
    end

    it 'works with nest T::Array' do
      expect {
        T::Coerce[T::Array[T.nilable(Integer)]].new.from(['1', 'invalid', '3'])
      }.to raise_error
      expect {
        T::Coerce[T::Array[T::Array[Integer]]].new.from([nil])
      }.to raise_error
      expect(
        T::Coerce[T::Array[T::Array[Integer]]].new.from([['1'], ['2'], ['3']]),
      ).to eql [[1], [2], [3]]

      expect(T::Coerce[
        T::Array[
          T::Array[
            T::Array[User]
          ]
        ]
      ].new.from([[[{id: '1'}]]]).flatten.first.id).to eql(1)

      expect(T::Coerce[
        T::Array[
          T::Array[
            T::Array[
              T::Array[
                T::Array[User]
              ]
            ]
          ]
        ]
      ].new.from(id: 1).flatten.first.id).to eql 1

      expect(T::Coerce[
        T.nilable(T::Array[T.nilable(T::Array[T.nilable(User)])])
      ].new.from([[{id: '1'}]]).flatten.map(&:id)).to eql([1])
    end
  end
end
