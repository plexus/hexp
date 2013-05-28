require 'delegate'

require 'nokogiri'
require 'ice_nine'
require 'equalizer'

module Hexp
  def self.deep_freeze(*args)
    IceNine.deep_freeze(*args)
  end
end

require 'hexp/version'
require 'hexp/triplet'
require 'hexp/triplet/normalize'
require 'hexp/triplet/domize'
require 'hexp/text_node'
require 'hexp/node_list'
require 'hexp/dom'
