Gem::Specification.new do |s|
  s.name          = %q{sorbet-coerce}
  s.version       = "0.1.6"
  s.date          = %q{2019-10-04}
  s.summary       = %q{A type coercion lib works with Sorbet's static type checker and type definitions; raises an error if the coercion fails.}
  s.authors       = ["Chan Zuckerberg Initiative"]
  s.email         = "opensource@chanzuckerberg.com"
  s.homepage      = "https://github.com/chanzuckerberg/sorbet-coerce"
  s.license       = 'MIT'
  s.require_paths = ["lib"]
  s.files         = Dir.glob('lib/**/*')
  s.files         += Dir.glob('spec/**/*')
  s.files         += Dir.glob('rbi/**/*')

  s.required_ruby_version = ['>= 2.3.0', '< 2.7.0']

  s.add_dependency 'sorbet', '~> 0.4.4704'

  s.add_runtime_dependency 'polyfill', '~> 1.8'
  s.add_runtime_dependency 'safe_type', '~> 1.1', '>= 1.1.1'
  s.add_runtime_dependency 'sorbet-runtime', '~> 0.4.4704'

  s.add_development_dependency 'rspec', '~> 3.8', '>= 3.8'
  s.add_development_dependency 'byebug', '~>11.0.1', '>=11.0.1'
end
