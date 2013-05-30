require 'spec_helper'

class Nokogiri::XML::Document
  include Equalizer.new(:name, :children)
end

class Nokogiri::XML::Node
  include Equalizer.new(:name, :attributes, :children)
end

describe Hexp::Node::Domize do
  subject { Hexp::Node::Domize.new( hexp ).() }

  describe 'a single node' do
    let(:hexp) { [:p, {}, []] }

    it 'should create a document with one node' do
      doc  = Hexp::DOM::Document.new
      doc << Hexp::DOM::Node.new('p', doc)

      p subject
      p doc
      p subject == doc

      subject.should == doc
    end
  end
end
