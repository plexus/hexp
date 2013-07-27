require 'spec_helper'

describe Hexp::CssSelector::Element do
  it 'should match elements with the same name' do
    expect(described_class.new('tag').matches?(H[:tag])).to be_true
  end

  it 'should not match elements with a different name' do
    expect(described_class.new('spane').matches?(H[:div])).to be_false
  end
end
