require 'spec_helper'

describe Hexp::Node, 'to_hexp' do
  let(:object) {Hexp::Node.new(:p) }
  subject { object.to_hexp }

  it { should == subject }
end
