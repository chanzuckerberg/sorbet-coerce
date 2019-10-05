source 'https://rubygems.org'

gemspec

group :test do
  gem 'codecov', require: false
  gem 'rake', require: false
  gem 'simplecov', require: false
end

sorbet_version = ENV["SORBET_VERSION"]
if sorbet_version
  # mostly used to test against a stable version of Sorbet in Travis.
  gem 'sorbet', sorbet_version
  gem 'sorbet-runtime', sorbet_version
else
  # prefer to test against latest version because sorbet is updated frequently
  gem 'sorbet'
  gem 'sorbet-runtime'
end

gem 'safe_type', '>= 1.1.1'
