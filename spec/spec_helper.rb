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

    # add_group 'Finalizer',    'lib/data_mapper/finalizer'

    minimum_coverage 98.51 # so the badge rounds up to 99
  end
end

require 'shared_helper'
