module Hexp
  class Unparser
    APOS   = ?'.freeze
    QUOT   = ?".freeze
    LT     = '<'.freeze
    GT     = '>'.freeze
    SPACE  = ' '.freeze
    EQ     = '='.freeze
    AMP    = '&'.freeze
    FSLASH = '/'.freeze

    E_AMP  = '&amp;'.freeze
    E_APOS = '&#x27;'.freeze
    E_QUOT = '&quot;'.freeze
    E_LT   = '&lt;'.freeze
    E_GT   = '&gt;'.freeze

    ESCAPE_ATTR_APOS = {AMP => E_AMP, APOS => E_APOS}
    ESCAPE_ATTR_QUOT = {AMP => E_AMP, QUOT => E_QUOT}
    ESCAPE_TEXT      = {AMP => E_AMP, APOS => E_APOS, QUOT => E_QUOT, LT => E_LT, GT => E_GT}

    ESCAPE_ATTR_APOS_REGEX = Regexp.new("[#{ESCAPE_ATTR_APOS.keys.join}]")
    ESCAPE_ATTR_QUOT_REGEX = Regexp.new("[#{ESCAPE_ATTR_QUOT.keys.join}]")
    ESCAPE_TEXT_REGEX      = Regexp.new("[#{ESCAPE_TEXT.keys.join}]")

    DEFAULT_OPTIONS = {
      encoding: Encoding.default_external
    }

    def initialize(options)
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def call(node)
      @buffer = String.new.force_encoding(@options[:encoding])
      add_node(node)
      @buffer.freeze
    end

    private

    def add_node(node)
      if node.text?
        @buffer << escape_text(node)
      else
        add_tag(node.tag, node.attributes, node.children)
      end
    end

    def add_tag(tag, attrs, children)
      @buffer << LT << tag.to_s
      unless attrs.empty?
        attrs.each {|k,v| add_attr(k,v)}
      end
      @buffer << GT
      children.each(&method(:add_node))
      @buffer << LT << FSLASH << tag.to_s << GT
    end

    def add_attr(key, value)
      @buffer << SPACE << key << EQ << fmt_attr_value(value)
    end

    def fmt_attr_value(value)
      ?' << value.gsub(ESCAPE_ATTR_APOS_REGEX, ESCAPE_ATTR_APOS) << ?'
    end

    def escape_text(text)
      text.gsub(ESCAPE_TEXT_REGEX, ESCAPE_TEXT)
    end
  end
end
