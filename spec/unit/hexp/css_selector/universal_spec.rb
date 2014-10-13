require 'spec_helper'

describe  Hexp::CssSelector::Universal do
  it 'should match everything' do
    expect(subject.matches? H[:section]).to be true
  end
end
