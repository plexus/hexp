require 'spec_helper'

describe Hexp::CssSelector::Parser do
  HC = Hexp::CssSelector # Is there really no way to include constant lookup in this namespace ?!

  subject(:parse_tree) { described_class.call(selector) }


  context 'with a single tag' do
    let(:selector) { 'body' }
    it {
      should eq HC::CommaSequence[HC::Element.new('body')]
    }
  end

  context 'with SASS specific syntax' do
    let(:selector) { '&.foo' }
    it 'should raise an exception' do
      expect{parse_tree}.to raise_exception
    end
  end

  context 'with an element, class and id specifier' do
    let(:selector) { '#main a.strong' }
    it {
      should eq HC::CommaSequence[
        HC::Sequence[
          HC::SimpleSequence[
            HC::Universal.new,
            HC::Id.new('main')],
          HC::SimpleSequence[
            HC::Element.new('a'),
            HC::Class.new('strong')]]]
    }
  end

  context 'with an attribute selector' do
    let(:selector) { 'div[link=href]' }
    it {
      should eq HC::CommaSequence[
          HC::SimpleSequence[
            HC::Element.new('div'),
            HC::Attribute.new('link', :equal, 'href'),
          ]]
    }
  end

end
