require 'spec_helper'

describe Hexp::Node, 'pp' do
  subject { object.pp }

  context 'with no attributes or children' do
    let(:object) { Hexp::Node[:p, {}] }
    it { should == 'Hexp::Node[:p]'}
  end

  context 'with a single child' do
    let(:object) { Hexp::Node[:p, [ [:abbr, {title: 'YAGNI'}, "You ain't gonna need it"] ]] }
    it { should == %q^Hexp::Node[:p, [
                        Hexp::Node[:abbr, {"title"=>"YAGNI"}, [
                          "You ain't gonna need it"]]]]^.gsub(' '*22, '')
    }
  end
end
