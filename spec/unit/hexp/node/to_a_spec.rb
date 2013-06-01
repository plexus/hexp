require 'spec_helper'

describe Hexp::Node, 'to_a' do
  subject { object.to_a }
  let(:object) { Hexp::Node.new(:p, class: 'foo') }

  it { should == [:p, {'class' => 'foo'}, Hexp::List[]] }
end
