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

desc "update gh-pages"
task :doc2gh do
  sh "git diff-files --quiet || exit 1"
  sh "git diff-index --quiet --cached HEAD || exit 1"
  sh "yardoc"
  sh "[ -d /tmp/doc ] && rm -rf /tmp/doc"
  sh "mv doc /tmp"
  sh "git co gh-pages"
  sh "rm -rf *"
  sh "cp -r /tmp/doc/* ."
  sh "git add ."
  sh "git commit -m 'Update gh-pages with YARD docs'"
  sh "git push origin gh-pages"
  sh "git co master"
end
