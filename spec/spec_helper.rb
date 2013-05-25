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

    # add_filter 'config'

    # add_group 'Finalizer',    'lib/data_mapper/finalizer'

    minimum_coverage 98.10  # 0.10 lower under JRuby
  end

end

require 'shared_helper'
