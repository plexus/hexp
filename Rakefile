require 'rubygems/package_task'

# Redefine rake:ci:metrics to disable rubocop, will tackle that laundry list
# some other time
# namespace :ci do
#   desc 'Run metrics (except mutant, rubocop) and spec'
#   task travis: %w[
#     metrics:coverage
#     spec:integration
#     metrics:yardstick:verify
#     metrics:flog
#     metrics:flay
#   ]
#   # metrics:reek
#   # metrics:rubocop
# end


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

require 'mutant'
task :default => :mutant

desc "run mutant"
task :mutant do
  pattern = ENV.fetch('PATTERN', 'Hexp*')
  opts    = ENV.fetch('MUTANT_OPTS', '').split(' ')
  result  = Mutant::CLI.run(%w[-Ilib -rhexp --use rspec --score 100] + opts + [pattern])
  fail unless result == Mutant::CLI::EXIT_SUCCESS
end

require 'rspec/core/rake_task'

desc "run rspec"
RSpec::Core::RakeTask.new(:rspec) do |t, task_args|
  t.rspec_opts = "-Ispec"
  t.pattern = "spec"
end
