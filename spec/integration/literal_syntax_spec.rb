require 'spec_helper'

describe 'Constructing literal hexps' do
  it do
    H[:p].should == Hexp::Node.new(:p, {}, [])
  end

  it do
    H[:p, "foo"].should == Hexp::Node.new(:p, {}, ["foo"])
  end

end
