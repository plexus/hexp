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
      # @return [String|Hexp::Node]
      # @api private
      #
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
      #   H[:option].attr?('selected') #=> false
      #
      # @param name [String|Symbol] the name of the attribute
      # @return [Boolean]
      # @api public
      #
      def attr?(name)
        attributes.has_key? name.to_s
      end

      # Check for the presence of a class
      #
      # @example
      #   H[:span, class: "banner strong"].class?("strong") #=> true
      #
      # @param klz [String] the name of the class to check for
      # @return [Boolean] true if the class is present, false otherwise
      # @api public
      #
      def class?(klz)
        attr('class') && attr('class').split(' ').include?(klz.to_s)
      end

      def add_class(klz)
        attr('class', [attr('class'), klz].compact.join(' '))
      end

      def class_list
        attr('class').split(' ')
      end

      def remove_class(klz)
        attr('class', class_list - [klz.to_s])
      end

      def set_attributes(attrs)
        H[
          self.tag,
          self.attributes.merge(Hash[*attrs.flat_map{|k,v| [k.to_s, v]}]),
          self.children
        ]
      end
      alias :% :set_attributes
      alias :add_attributes :set_attributes

      def remove_attr(name)
        H[
          self.tag,
          self.attributes.reject {|k,v| k == name.to_s},
          self.children
        ]
      end

      def [](attribute)
        self.attributes[attribute.to_s]
      end

    end
  end
end
