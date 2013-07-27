# encoding: utf-8

# SimpleCov MUST be started before require 'hexp'
#
if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    command_name 'spec:unit'
    add_filter 'hexp/h.rb'

    minimum_coverage 99.0
  end
end

require 'shared_helper'
