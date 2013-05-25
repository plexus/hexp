require 'spec_helper'

describe Hexp::Triplet::Normalize, '#call' do
  subject { Hexp::Triplet::Normalize.new(triplet).() }

  describe 'with a single element' do
    let (:triplet) { [:div] }

    its(:count) { should == 3 }

    it 'should treat the first as the tag' do
      subject[0].should == :div
    end
    it 'should set an empty attribute list' do
      subject[1].should == {}
    end
    it 'should set an empty children list' do
      subject[2].should == []
    end
  end

  describe 'with two parameters' do
    let (:triplet) { [:div, {class: 'foo'}] }

    it 'should treat the first as the tag' do
      subject[0].should == :div
    end
    it 'should treat the second as the attribute list, if it is a Hash' do
      subject[1].should == {class: 'foo'}
    end
    it 'should treat the second as a list of children, if it is an Array' do
      subject[2].should == []
    end
  end

  describe 'with a single text child node' do
    let(:triplet) { [:div, "this is text in the div"] }

    it 'should set is as the single child' do
      subject[2].should == ["this is text in the div"]
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
      subject[2].should == [
        [:h1, {},                  ["Big Title"]   ],
        [:p,  {class: 'greeting'}, ["hello world"] ],
        "Some loose text"
      ]
    end
  end

end
