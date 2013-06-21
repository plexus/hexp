module Hexp
  # Raised when something is requested that is impossible to fulfill, like adding
  # an attribute to a text node.
  class IllegalRequestError < ArgumentError
  end
end
