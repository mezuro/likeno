# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'likeno/version'

Gem::Specification.new do |spec|
  spec.name          = 'likeno'
  spec.version       = Likeno::VERSION
  spec.authors       = ['Heitor Reis', 'Diego de Araújo Martinez Camarinha', 'Rafael Reggiani Manzo']
  spec.email         = ['mezurometrics@gmail.com']

  spec.summary       = 'Symbiotic connection between organisms'
  spec.description   = 'Connects services through a RESTful API'
  spec.homepage      = 'https://github.com/mezuro/likeno'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2.2'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 11.1'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'factory_girl', '~> 4.5.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'codeclimate-test-reporter'

  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'activesupport', '>= 2.2.1'
end
