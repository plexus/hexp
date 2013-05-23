# encoding: utf-8

require_relative 'lib/hexp/version'

Gem::Specification.new do |gem|
  gem.name        = 'gemspec'
  gem.version     = Hexp::VERSION
  gem.authors     = [ 'Arne Brasseur' ]
  gem.email       = [ 'arne@arnebrasseur.net' ]
  gem.description = 'HTML expressions'
  gem.summary     = gem.description
  gem.homepage    = 'https://github.com/plexus/hexp'

  gem.require_paths    = %w[lib]
  gem.files            = `git ls-files`.split($/)
  gem.test_files       = `git ls-files -- spec`.split($/)
  gem.extra_rdoc_files = %w[README.md]

  gem.add_dependency 'ice_nine', '~> 0.7.0'
end
