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
end
