require 'devtools'
require 'rubygems/package_task'

Devtools.init_rake_tasks

# Redefine rake:ci:metrics to disable rubocop, will tackle that laundry list
# some other time
namespace :ci do
  desc 'Run metrics (except mutant, rubocop) and spec'
  task travis: %w[
    metrics:coverage
    spec:integration
    metrics:yardstick:verify
    metrics:flog
    metrics:flay
    metrics:reek
  ]
  # metrics:rubocop
end


spec = Gem::Specification.load(File.expand_path('../hexp.gemspec', __FILE__))
gem = Gem::PackageTask.new(spec)
gem.define

desc "Push gem to rubygems.org"
task :push => :gem do
  sh "git tag v#{Hexp::VERSION}"
  sh "git push --tags"
  sh "gem push pkg/hexp-#{Hexp::VERSION}.gem"
end
