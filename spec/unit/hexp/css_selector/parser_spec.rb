require 'spec_helper'

describe Hexp::CssSelector::Parser do
  HCSS = Hexp::CssSelector

  subject(:parse_tree) { described_class.call(selector) }

  context 'with a single tag' do
    include Hexp::CssSelector
    let(:selector) { 'body' }
    it {
      should eq HCSS::CommaSequence[
        HCSS::Sequence[
          HCSS::SimpleSequence[
            HCSS::Element.new('body')]]]
    }
  end
end
