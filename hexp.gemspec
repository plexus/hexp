# encoding: utf-8

require File.expand_path('../lib/hexp/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'hexp'
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

  gem.add_dependency 'sass'      , '~> 3.2.9'
  gem.add_dependency 'nokogiri'  , '~> 1.5.9'
  gem.add_dependency 'ice_nine'  , '~> 0.7.0'
  gem.add_dependency 'equalizer' , '~> 0.0.5'
end
