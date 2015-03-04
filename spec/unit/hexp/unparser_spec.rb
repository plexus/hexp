require 'spec_helper'

describe Hexp::Unparser do
  let(:unparser) { described_class.new({}) }
  let(:node) { H[:p, %q{Hello "world", it's great meet & chat >.<}] }
  let(:html) { unparser.call(node) }

  it 'should escape sensitive characters' do
    expect(html).to eql '<p>Hello &quot;world&quot;, it&#x27;s great meet &amp; chat &gt;.&lt;</p>'
  end

  context 'inside a script tag' do
    let(:node) { H[:script, %q{Hello "world", }, %q{it's great meet & chat >.<}] }

    it 'should not escape' do
      expect(html).to eql %q{<script>Hello "world", it's great meet & chat >.<</script>}
    end
  end
end
