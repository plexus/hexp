require 'devtools'
require 'rubygems/package_task'

Devtools.init_rake_tasks

spec = Gem::Specification.load(File.expand_path('../hexp.gemspec', __FILE__))
gem = Gem::PackageTask.new(spec)
gem.define
