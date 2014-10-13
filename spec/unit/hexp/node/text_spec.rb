require 'spec_helper'

describe Hexp::Node do
  subject { described_class[:p] }

  its(:text?) { should be false }
end
