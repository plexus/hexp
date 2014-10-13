require 'spec_helper'

describe 'Constructing literal hexps' do
  it do
    expect(H[:p]).to eql Hexp::Node.new(:p, {}, [])
  end

  it do
    expect(H[:p, "foo"]).to eql Hexp::Node.new(:p, {}, ["foo"])
  end

end
