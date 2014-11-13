module Hexp
  class Node
    # Node API methods that deal with attributes
    #
    module Attributes
      # Attribute getter/setter
      #
      # When called with one argument : return the attribute value with that name.
      # When called with two arguments : return a new Node with the attribute set.
      # When the second argument is nil : return a new Node with the attribute unset.
      #
      # @example
      #    H[:p, class: 'hello'].attr('class')       # => "hello"
      #    H[:p, class: 'hello'].attr('id', 'para1') # => H[:p, {"class"=>"hello", "id"=>"para1"}]
      #    H[:p, class: 'hello'].attr('class', nil)  # => H[:p]
      #
      # @param [Array<#to_s>] args
      # @return [String|Hexp::Node]
      #
      # @api private
      def attr(*args)
        arity     = args.count
        attr_name = args[0].to_s

        case arity
        when 1
          attributes[attr_name]
        when 2
          set_attr(*args)
        else
          raise ArgumentError, "wrong number of arguments(#{arity} for 1..2)"
        end
      end

      # Is an attribute present
      #
      # This will also return true if the attribute is present but empty.
      #
      # @example
      #   H[:option].has_attr?('selected') #=> false
      #
      # @param [String|Symbol] name
      #   The name of the attribute
      #
      # @return [true,false]
      #
      # @api public
      def has_attr?(name)
        attributes.has_key? name.to_s
      end

      # Check for the presence of a class
      #
      # @example
      #   H[:span, class: "banner strong"].class?("strong") #=> true
      #
      # @param [String] klass
      #   The name of the class to check for
      #
      # @return [Boolean]
      #   True if the class is present, false otherwise
      #
      # @api public
      def class?(klass)
        attr('class') && attr('class').split(' ').include?(klass.to_s)
      end

      # Add a CSS class to the element
      #
      # @example
      #   H[:div].add_class('foo') #=> H[:div, class: 'foo']
      #
      # @param [#to_s] klass
      #   The class to add
      #
      # @return [Hexp::Node]
      #
      # @api public
      def add_class(klass)
        attr('class', [attr('class'), klass].compact.join(' '))
      end

      # The CSS classes of this element as an array
      #
      # Convenience method so you don't have to split the class list yourself.
      #
      # @return [Array<String>]
      #
      # @api public
      def class_list
        @class_list ||= (attr('class') || '').split(' ')
      end

      # Remove a CSS class from this element
      #
      # If the resulting class list is empty, the class attribute will be
      # removed. If the class is present several times all instances will
      # be removed. If it's not present at all, the class list will be
      # unmodified.
      #
      # Calling this on a node with a class attribute that is equal to an
      # empty string will result in the class attribute being removed.
      #
      # @param [#to_s] klass
      #   The class to be removed
      # @return [Hexp::Node]
      #   A node that is identical to this one, but with the given class removed
      #
      # @api public
      def remove_class(klass)
        return self unless has_attr?('class')
        new_list = class_list - [klass.to_s]
        return remove_attr('class') if new_list.empty?
        attr('class', new_list.join(' '))
      end

      # Set or override multiple attributes using a hash syntax
      #
      # @param [Hash<#to_s,#to_s>] attrs
      #
      # @return [Hexp::Node]
      #
      # @api public
      def set_attrs(attrs)
        H[
          self.tag,
          Hash[*attrs.flat_map{|k,v| [k.to_s, v]}],
          self.children
        ]
      end

      # Remove an attribute by name
      #
      # @param [#to_s] name
      #   The attribute to be removed
      #
      # @return [Hexp::Node]
      #   A new node with the attribute removed
      #
      # @api public
      def remove_attr(name)
        H[
          self.tag,
          self.attributes.reject {|key,_| key == name.to_s},
          self.children
        ]
      end

      # Attribute accessor
      #
      # @param_name [#to_s] attr
      #   The name of the attribute
      #
      # @return [String]
      #   The value of the attribute
      #
      # @api public
      def [](attr_name)
        self.attributes[attr_name.to_s]
      end

      # Merge attributes into this Hexp
      #
      # Class attributes are treated special : the class lists are merged, rather
      # than being overwritten. See {#set_attrs} for a more basic version.
      #
      # This method is analoguous with `Hash#merge`. As argument it can take a
      # Hash, or another Hexp element, in which case that element's attributes
      # are used.
      #
      # @param_or_hash [#to_hexp|Hash] node
      #
      # @return [Hexp::Node]
      #
      # @api public
      def merge_attrs(node_or_hash)
        hash = node_or_hash.respond_to?(:to_hexp) ?
                 node_or_hash.to_hexp.attributes : node_or_hash
        result = self
        hash.each do |key,value|
          result = if key.to_s == 'class'
                     result.add_class(value)
                   else
                     result.attr(key, value)
                   end
        end
        result
      end
      alias :% :merge_attrs

    end
  end
end
