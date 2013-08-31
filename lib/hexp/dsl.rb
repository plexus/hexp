module Hexp
  # Make the Hexp::Node DSL available to objects that implement `to_hexp`
  #
  # Mixing in {Hexp} has the same effect as mixing in {Hexp::DSL}, and is the
  # recommended way.
  #
  module DSL
    # The names of methods related to manipulating the list of children of a node
    CHILDREN_METHODS   = Hexp::Node::Children.public_instance_methods.freeze

    # The names of methods related to a node's attributes
    ATTRIBUTES_METHODS = Hexp::Node::Attributes.public_instance_methods.freeze

    # Methods that are defined directly in {Hexp::Node}
    NODE_METHODS = Hexp::Node.public_instance_methods(false) - [
      :to_hexp,
      :inspect
    ]

    [CHILDREN_METHODS, ATTRIBUTES_METHODS, NODE_METHODS].flatten.each do |method|
      define_method method do |*args, &blk|
        to_hexp.public_send(method, *args, &blk)
      end
    end
  end
end
