require 'delegate'
require 'forwardable'

require 'nokogiri'
require 'ice_nine'
require 'equalizer'

module Hexp
  # Deep freeze an object
  #
  # Delegates to IceNine
  #
  # @param args [Array] arguments to pass on
  # @return Object
  # @api private
  #
  def self.deep_freeze(*args)
    IceNine.deep_freeze(*args)
  end

  # Variant of ::Array with slightly modified semantics
  #
  # Array() is often used to wrap a value in an Array, unless it's already
  # an array. However if your object implements #to_a, then Array() will use
  # that value. Because of this objects that aren't Array-like will get
  # converted as well, such as Struct objects.
  #
  # This implementation relies on #to_ary, which signals that the Object is
  # a drop-in replacement for an actual Array.
  #
  # @param arg [Object]
  # @return [Array]
  # @api private
  #
  def self.Array(arg)
    if arg.respond_to? :to_ary
      arg.to_ary
    else
      [ arg ]
    end
  end
end

require 'hexp/version'

require 'hexp/node'
require 'hexp/node/normalize'
require 'hexp/node/domize'
require 'hexp/node/pp'

require 'hexp/text_node'
require 'hexp/list'
require 'hexp/dom'

require 'hexp/format_error.rb'
require 'hexp/illegal_request_error.rb'

require 'hexp/nokogiri/equality'

require 'hexp/dsl'
require 'hexp/h'

module Hexp
  # Inject the Hexp::DSL module into classes that include Hexp
  #
  # @param klazz [Class] The class that included Hexp
  #
  # @return [Class]
  # @api private
  #
  def self.included(klazz)
    klazz.send(:include, Hexp::DSL)
  end
end
