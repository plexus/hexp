require 'spec_helper'

describe Hexp::Triplet::Normalize, '#call' do
  subject { Hexp::Triplet[*triplet] }

  describe 'with a single element' do
    let (:triplet) { [:div] }

    it 'should treat the first as the tag' do
      subject.tag.should == :div
    end
    it 'should set an empty attribute list' do
      subject.attributes.should == {}
    end
    it 'should set an empty children list' do
      subject.children.should == []
    end
  end

  describe 'with two parameters' do
    let (:triplet) { [:div, {class: 'foo'}] }

    it 'should treat the first as the tag' do
      subject.tag.should == :div
    end
    it 'should treat the second as the attribute list, if it is a Hash' do
      subject.attributes.should == {class: 'foo'}
    end
    it 'should treat the second as a list of children, if it is an Array' do
      subject.children.should == []
    end
  end

  describe 'with a single text child node' do
    let(:triplet) { [:div, "this is text in the div"] }

    it 'should set is as the single child' do
      subject.children.should == Hexp::NodeList["this is text in the div"]
    end
  end

  describe 'with child nodes' do
    let(:triplet) {
      [:div, [
          [:h1, "Big Title"],
          [:p, {class: 'greeting'}, "hello world"],
          "Some loose text"
        ]
      ]
    }

    it 'must normalize them recursively' do
      subject.children.should == Hexp::NodeList[
        Hexp::Triplet[:h1, {},                  Hexp::NodeList["Big Title"]   ],
        Hexp::Triplet[:p,  {class: 'greeting'}, Hexp::NodeList["hello world"] ],
        "Some loose text"
      ]
    end
  end

end
