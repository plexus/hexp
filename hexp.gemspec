# encoding: utf-8

require File.expand_path('../lib/hexp/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'hexp'
  gem.version     = Hexp::VERSION
  gem.authors     = [ 'Arne Brasseur' ]
  gem.email       = [ 'arne@arnebrasseur.net' ]
  gem.description = 'Generate and manipulate HTML documents and nodes.'
  gem.summary     = gem.description
  gem.homepage    = 'https://github.com/plexus/hexp'
  gem.license     = 'MIT'

  gem.require_paths    = %w[lib]
  gem.files            = `git ls-files`.split($/)
  gem.test_files       = `git ls-files -- spec`.split($/)
  gem.extra_rdoc_files = %w[README.md]

  gem.add_runtime_dependency 'sass', '~> 3.2.0'
  gem.add_runtime_dependency 'nokogiri', '~> 1.6'
  gem.add_runtime_dependency 'ice_nine', '~> 0.9'
  gem.add_runtime_dependency 'equalizer', '~> 0.0'

  gem.add_development_dependency 'rake', '~> 10.1'
  gem.add_development_dependency 'rspec', '~> 2.14'
  gem.add_development_dependency 'benchmark_suite', '~> 1.0'
end
