require 'spec_helper'

describe Hexp::CssSelector::Class do
  it 'should match elements having the giving class' do
    expect(described_class.new('big').matches?(H[:div, class: 'big'])).to be true
  end

  it 'should not match elements not having the given class' do
    expect(described_class.new('big').matches?(H[:div, class: 'small'])).to be false
  end

  it 'should work with elements with multiple classes' do
    expect(described_class.new('foo').matches?(H[:div, class: 'foo bar'])).to be true
  end
end
