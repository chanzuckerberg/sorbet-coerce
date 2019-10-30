# typed: strict
require 'byebug'
require 'simplecov'

SimpleCov.start

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end

RSpec::Expectations.configuration.on_potential_false_positives = :nothing
