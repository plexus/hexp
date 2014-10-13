require 'spec_helper'

describe Hexp::CssSelector::SimpleSequence do
  context 'with a single element member' do
    let(:sequence) { described_class[Hexp::CssSelector::Element.new('div')] }

    it 'should match when the element has the same tag name' do
      expect(sequence.matches?(H[:div])).to be true
    end

    it 'should not match when the tag name differs' do
      expect(sequence.matches?(H[:span])).to be false
    end
  end

  context 'with a single class member' do
    let(:sequence) { described_class[Hexp::CssSelector::Class.new('mega')] }

    it 'should match when the element has a class by that name' do
      expect(sequence.matches?(H[:div, class: 'mega'])).to be true
    end

    it 'should not match when the element has no classes' do
      expect(sequence.matches?(H[:span])).to be false
    end

    it 'should not match when the element has no classes by that name' do
      expect(sequence.matches?(H[:span, class: 'megalopolis'])).to be false
    end
  end

  context 'with an element and class' do
    let(:sequence) do described_class[
        Hexp::CssSelector::Element.new('div'),
        Hexp::CssSelector::Class.new('mega')
      ]
    end

    it 'should match if all parts are satisfied' do
      expect(sequence.matches?(H[:div, class: 'mega'])).to be true
    end

    it 'should not match if one parts is not satisfied' do
      expect(sequence.matches?(H[:div, class: 'foo'])).to be false
      expect(sequence.matches?(H[:span, class: 'mega'])).to be false
    end
  end
end
