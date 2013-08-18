require 'delegate'
require 'forwardable'

require 'nokogiri' # TODO => replace with Builder
require 'sass'
require 'ice_nine'
require 'equalizer'

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

  def self.parse(html)
    Hexp::Nokogiri::Reader.new.call(
      Nokogiri(html).root
    )
  end

  # Use builder syntax to create a Hexp
  #
  # (see Hexp::Builder)
  #
  # @example
  #   list = Hexp.build do
  #     ul do
  #      3.times do |i|
  #        li i.to_s
  #      end
  #     end
  #   end
  #
  # @param args [Array]
  # @return [Hexp::Builder]
  # @api public
  #
  def self.build(*args, &block)
    Hexp::Builder.new(*args, &block)
  end

end

require 'hexp/version'
require 'hexp/dsl'


require 'hexp/node/attributes'
require 'hexp/node/children'

require 'hexp/node'
require 'hexp/node/normalize'
require 'hexp/node/domize'
require 'hexp/node/pp'
require 'hexp/node/rewriter'
require 'hexp/node/selector'
require 'hexp/node/css_selection'

require 'hexp/text_node'
require 'hexp/list'
require 'hexp/dom'

require 'hexp/css_selector'
require 'hexp/css_selector/sass_parser'
require 'hexp/css_selector/parser'

require 'hexp/errors'

require 'hexp/nokogiri/equality' # TODO => replace this with equivalent-xml
require 'hexp/nokogiri/reader'
require 'hexp/sass/selector_parser'

require 'hexp/h'

require 'hexp/builder'
