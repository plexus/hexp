require 'hexp'
require 'rspec/its'

RSpec::Matchers.define :dom_eq do |other_dom|
  match do |dom|
    Hexp::Nokogiri::Equality.new(dom, other_dom).call
  end
end

RSpec.configure do |rspec|
  rspec.mock_with :rspec do |configuration|
    configuration.syntax = :expect
  end
  rspec.around(:each) do |example|
    Timeout.timeout(1, &example)
  end
end
