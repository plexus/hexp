require 'spec_helper'

describe Hexp::CssSelector::CommaSequence do
  it 'has members' do
    described_class.new([:foo]).members == [:foo]
  end
end
