require 'spec_helper'

describe Hexp::Node, 'to_html' do
  subject { Hexp::Node[:tt] }

  it 'should render HTML' do
    expect(subject.to_html).to eql '<tt></tt>'
  end

  describe 'attribute escaping' do
    subject { Hexp::Node[:foo, {bar: "it's fine&dandy"}] }

    it 'should escape ampersand, single quote' do
      expect(subject.to_html).to eql "<foo bar='it&#x27;s fine&amp;dandy'></foo>"
    end
  end

  describe 'text node escaping' do
    subject { Hexp::Node[:foo, "it's 5 > 3, & 6 < 3, \"fine chap\""] }

    it 'should escape ampersand, single quote, double quote, lower than, greater than' do
      expect(subject.to_html).to eql "<foo>it&#x27;s 5 &gt; 3, &amp; 6 &lt; 3, &quot;fine chap&quot;</foo>"
    end
  end
end
