module Hexp
  # A Hexp Node
  class Node
    include Equalizer.new(:tag, :attributes, :children)
    attr_reader :tag, :attributes, :children

    def initialize(tag, attributes, children)
      @tag, @attributes, @children = Hexp.deep_freeze([tag, attributes, children])
    end

    # Array-style constructor, but normalize the arguments
    #
    # @param args [Array] args a Hexp node
    # @return [Hexp::Node]
    #
    # @example
    #    Hexp::Node[:p, {'class' => 'foo'}, [[:b, "Hello, World!"]]]
    #
    # @api public
    def self.[](*args)
      new(*Normalize.new(args).call)
    end

    def to_hexp
      self
    end

    def to_html
      to_dom.to_html
    end

    def to_dom
      Domize.new(self).call
    end

    def inspect
      self.class.inspect_name + [
        tag,
        attributes.empty? ? nil : attributes,
        children.empty?   ? nil : children,
      ].compact.inspect
    end

    def to_a
      [tag, attributes, children]
    end

    def pp(indent=0)
      out = self.class.inspect_name
      out << "[#{tag.inspect}"
      out << (attributes.empty? ? ''  : (', ' + attributes.inspect))
      out << (children.empty?   ? ']' : (", [\n" + children.map{|child| child.pp(indent+1)}.join(",\n") + "]]"))
      out.lines.map{|line| "  "*indent + line}.join
    end

    def filter(*filters, &blk)
      filters = [*filters, blk].compact
      return self if filters.empty?
      self.class[tag, attributes, apply_filter(filters.first)]#.filter(*filters[1..-1])
    end

    def apply_filter(filter)
      children.flat_map do |node|
        if filter.arity == 1
          filter.call(node)
        elsif filter.arity == 3
          filter.call(*node)
        end
      end.map do |node|
        (node.instance_of?(String) || node.instance_of?(TextNode) ? node : H[*node].filter(filter))
      end
      # self.class[*
      #   to_enum(:breadth_first_walk).flat_map do |node|
      #     filter.call(node) if filter.arity == 1
      #     filter.call(node.tag, node.attributes, node.children) if filter.arity == 3
      #   end.first
      # ]
    end

    def breadth_first_walk(&blk)
      blk.call(self)
      children.each{|child| child.tree_walk(&blk)}
    end

    class << self
      def inspect_name
        if defined?(H) && H == self
          'H'
        else
          self.class.name
        end
      end
    end
  end
end
