require 'spec_helper'

describe Hexp::Node, 'pp' do
  subject { object.pp }

  context 'with no attributes or children' do
    let(:object) { H[:p, {}] }
    it { should == 'H[:p]'}
  end

  context 'with a single child' do
    let(:object) { H[:p, [ [:abbr, {title: 'YAGNI'}, "You ain't gonna need it"] ]] }
    it { should == %q^H[:p, [
                        H[:abbr, {"title"=>"YAGNI"}, [
                          "You ain't gonna need it"]]]]^.gsub(' '*22, '')
    }
  end
end
