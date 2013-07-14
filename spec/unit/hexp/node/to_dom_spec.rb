require 'spec_helper'

describe Hexp::Node, 'to_dom' do
  subject { Hexp::Node[:blink] }

  it 'should delegate to Domize' do
    expect(Hexp::Node::Domize).to receive(:new).with(subject).and_return( ->{ 'result' } )
    subject.to_dom.should == 'result'
  end
end
