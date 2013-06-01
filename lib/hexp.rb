require 'delegate'
require 'forwardable'

require 'nokogiri'
require 'ice_nine'
require 'equalizer'

module Hexp
  def self.deep_freeze(*args)
    IceNine.deep_freeze(*args)
  end
end

require 'hexp/version'
require 'hexp/node'
require 'hexp/node/normalize'
require 'hexp/node/domize'
require 'hexp/text_node'
require 'hexp/list'
require 'hexp/dom'

require 'hexp/nokogiri/equality'
