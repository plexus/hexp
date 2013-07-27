require 'spec_helper'

describe Hexp::CssSelector::CommaSequence do
  let(:comma_sequence) { Hexp::CssSelector::Parser.call(selector) }

  it 'has members' do
    described_class.new([:foo]).members == [:foo]
  end

  describe '#matches?' do
    context do
      let(:selector) { 'ul li, li' }
      let(:element)  { H[:li, class: 'baz'] }

      it 'should match' do
        expect(comma_sequence.matches?(element)).to be_true
      end
    end
  end
end
