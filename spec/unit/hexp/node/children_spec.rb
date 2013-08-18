require 'spec_helper'

describe Hexp::Node::Children do
  describe 'empty?' do
    context 'for an empty node' do
      subject { H[:div] }
      it { should be_empty }
    end

    context 'for a node with children' do
      subject { H[:div, [H[:span, "hello"]]] }
      it { should_not be_empty }
    end
  end

  describe 'add_child' do
    it 'should return a new node with the child added' do
      expect(H[:div].add_child(H[:span])).to eq H[:div, H[:span]]
    end
  end

  describe 'text' do
    it 'should return all text nodes that are descendant of this node, combined' do
      expect(H[:div, [
            "Hello,",
            H[:span, {class: 'big'}, "World!"]
          ]
        ].text
      ).to eq "Hello,World!"
    end
  end

end
