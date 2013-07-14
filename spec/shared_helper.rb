require 'hexp'
require 'devtools/spec_helper'

RSpec::Matchers.define :dom_eq do |other_dom|
  match do |dom|
    Hexp::Nokogiri::Equality.new(dom, other_dom).call
  end
end

RSpec.configure do |configuration|
  configuration.mock_with :rspec do |configuration|
    configuration.syntax = :expect
  end
end
