require 'spec_helper'

describe Hexp::CssSelector::Attribute do
  subject(:selector) { described_class.new(name, namespace, operator, value, flags) }
  let(:name)      { nil }
  let(:namespace) { nil }
  let(:operator)  { nil }
  let(:value)     { nil }
  let(:flags)     { nil }

  describe 'without an operator' do
    let(:name) { 'href' }

    it 'should match elements with the attribute present' do
      expect(selector.matches? H[:a, href: 'http://foo']).to be true
    end

    it 'should match elements with an empty attribute present' do
      expect(selector.matches? H[:a, href: '']).to be true
    end

    it 'should not match elements without the attribute present' do
      expect(selector.matches? H[:a]).to be false
    end
  end

  describe 'with the "=" operator' do
    let(:name)     { 'class' }
    let(:operator) { '=' }
    let(:value)    { 'foo' }

    it "should match if the attribute's value is exactly equal to the given value" do
      expect(selector.matches? H[:a, class: 'foo']).to be true
    end

    it "should not match if the attribute's value contains more than the given value" do
      expect(selector.matches? H[:a, class: 'foofoo']).to be false
    end

    it "should not match if the attribute's value does not contain the given value" do
      expect(selector.matches? H[:a, class: 'fo']).to be false
    end
  end

  describe 'the "~=" operator' do
    let(:name)     { 'class' }
    let(:operator) { '~=' }
    let(:value)    { 'foo' }

    it 'should match an entry in a space separated list' do
      expect(selector.matches? H[:a, class: 'foo bla baz']).to be true
    end

    it 'should return false if there is no entry that matches' do
      expect(selector.matches? H[:a, class: 'bla baz']).to be false
    end

    it 'should return false if there is no such attribute' do
      expect(selector.matches? H[:a]).to be false
    end
  end

  describe 'the "|=" operator' do
    let(:name)     { 'id' }
    let(:operator) { '|=' }
    let(:value)    { 'foo' }

    it 'should match if the attribute starts with the value, followed by a dash' do
      expect(selector.matches? H[:a, id: 'foo-1']).to be_truthy
    end

    it 'should not match if the value is not at the start' do
      expect(selector.matches? H[:a, id: 'myfoo-1']).to be_falsey
    end

    it 'should not match if the value is not followed by a dash' do
      expect(selector.matches? H[:a, id: 'foo1']).to be_falsey
    end
  end

  describe 'the "^=" operator' do
    let(:name)     { 'id' }
    let(:operator) { '^=' }
    let(:value)    { 'foo' }

    it 'should match if the attribute is just the value' do
      expect(selector.matches? H[:a, id: 'foo']).to be true
    end

    it 'should match if the attribute starts with the value' do
      expect(selector.matches? H[:a, id: 'foohi']).to be true
    end

    it 'should not match if the value is not at the start' do
      expect(selector.matches? H[:a, id: 'myfoo-1']).to be false
    end
  end

  describe 'the "$=" operator' do
    let(:name)     { 'id' }
    let(:operator) { '$=' }
    let(:value)    { 'foo' }

    it 'should match if the attribute is just the value' do
      expect(selector.matches? H[:a, id: 'foo']).to be_truthy
    end

    it 'should match if the attribute ends starts with the value' do
      expect(selector.matches? H[:a, id: 'hifoo']).to be_truthy
    end

    it 'should not match if the value is not at the end' do
      expect(selector.matches? H[:a, id: 'foo-1']).to be_falsey
    end
  end

  describe 'the "*=" operator' do
    let(:name)     { 'id' }
    let(:operator) { '*=' }
    let(:value)    { 'foo' }

    it 'should match if the attribute is just the value' do
      expect(selector.matches? H[:a, id: 'foo']).to be true
    end

    it 'should match if the attribute starts starts with the value' do
      expect(selector.matches? H[:a, id: 'foohi']).to be true
    end

    it 'should match if the attribute ends starts with the value' do
      expect(selector.matches? H[:a, id: 'hifoo']).to be true
    end

    it 'should not match if the value is not in the attribute' do
      expect(selector.matches? H[:a, id: 'yomofohoho']).to be false
    end
  end

  describe '$= with quoted string values' do
    subject(:selector) { Hexp::CssSelector::Parser.new('[src$="foo/bar.js"]').parse }

    it 'should match correctly' do
      expect(selector.matches? H[:script, src: "/tmp/foo/bar.js"]).to be true
    end

    it 'should only match at the end' do
      expect(selector.matches? H[:script, src: "/tmp/foo/bar.jsx"]).to be false
    end
  end
end
