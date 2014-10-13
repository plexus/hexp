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
    its(:text?)   { should be true }
    its(:rewrite) { should eq(subject) }
    its(:to_hexp) { should eq(subject) }

    describe 'class?' do
      it 'should always return false' do
        expect(subject.class?('strong')).to be false
      end
    end
  end
end
