require 'spec_helper'

describe Hexp::Node::Domize do
  def build_doc(&blk)
    Nokogiri::HTML::Builder.new(&blk).doc
  end

  subject { Hexp::Node::Domize.new(hexp).call }

  context 'with the same single node' do
    let(:dom) { build_doc { html } }
    let(:hexp) { Hexp::Node[:html] }

    it { should dom_eq(dom) }
  end

  context 'with a different single node' do
    let(:dom) { build_doc { html } }
    let(:hexp) { Hexp::Node[:body] }

    it { should_not dom_eq(dom) }
  end

  context 'with nested nodes' do
    let(:dom) { build_doc { html { div(class: 'big') } } }
    let(:hexp) { Hexp::Node[:html, [ [:div, class: 'big'] ]] }

    it { should dom_eq(dom) }
  end

  context 'with equal text nodes' do
    let(:dom) { build_doc {
        html do
          div(class: 'big')
          text "awesometown!"
        end
    } }
    let(:hexp) {
      Hexp::Node[:html, [
          [:div, class: 'big'],
          "awesometown!"
        ]
      ]
    }

    it { should dom_eq(dom) }
  end

  context 'with differing text nodes' do
    let(:dom) { build_doc {
        html do
          div(class: 'big')
          text "awesomevillage!"
        end
    } }
    let(:hexp) {
      Hexp::Node[:html, [
          [:div, class: 'big'],
          "awesometown!"
        ]
      ]
    }

    it { should_not dom_eq(dom) }
  end

  context 'with the :html5 option' do
    let(:hexp) { Hexp::Node[:html] }

    it 'should set a HTML5 style doctype' do
      dtd = hexp.to_dom(html5: true).children.first
      expect(dtd).to be_a Nokogiri::XML::DTD
      expect(dtd.name).to be_nil
      expect(dtd.external_id).to be_nil
      expect(dtd.system_id).to be_nil
    end
  end
end
