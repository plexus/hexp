require 'spec_helper'

describe Hexp::TextNode do
  subject { described_class.new('some string') }

  describe 'Node triplet' do
    its(:tag)        { should be_nil }
    its(:attributes) { should eq({}) }
    its(:attributes) { should be_frozen }
    its(:children)   { should eq([]) }
    its(:children)   { should be_frozen }
  end

  describe 'DSL methods' do
    describe 'attr' do
      it 'should ignore attr set requests' do
        expect(subject.attr('class', 'foo')).to be_nil
      end

      it 'should return nil for attr get requests' do
        expect(subject.attr('class')).to be_nil
      end
    end

    its(:text?)   { should be_true }
    its(:rewrite) { should eq(subject) }
    its(:to_hexp) { should eq(subject) }
  end
end
