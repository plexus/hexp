require 'spec_helper'

describe Hexp::Node, 'to_html' do
  subject { Hexp::Node[:tt] }

  it 'should render HTML' do
    subject.to_html.should =~ %r{<tt></tt>}
  end
end
