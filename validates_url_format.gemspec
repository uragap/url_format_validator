require_relative 'lib/validates_url_format/version'

Gem::Specification.new do |spec|
  spec.name          = 'validates_url_format'
  spec.version       = ValidatesUrlFormat::VERSION
  spec.authors       = ['Yury Hapanovich', 'EComCharge']
  spec.email         = ['yury.gapanovich@ecomcharge.com']

  spec.summary       = 'Library for validating urls using ActiveModel.'
  spec.description   = 'Library for validating urls using ActiveModel.'
  spec.homepage      = 'https://github.com/uragap/validates_url_format'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/uragap/validates_url_format'
  spec.metadata['changelog_uri'] = 'https://github.com/uragap/validates_url_format'

  spec.files = `git ls-files`.split("\n")
  spec.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 3.2'
  spec.add_dependency 'public_suffix'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
