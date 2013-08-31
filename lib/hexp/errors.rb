module Hexp
  # Base class for exceptions raised by Hexp
  #
  Error = Class.new(StandardError)

  # Raised when trying to stick things inside a Hexp where they don't belong
  #
  class FormatError < Error
    # Create a new FormatError
    #
    # @api private
    def initialize(msg = 'You have illegal contents in your Hexp')
      super
    end
  end

  # Raised by {Hexp.parse} when the input can't be converted to a {Hexp::Node}
  #
  class ParseError < Error
  end
end
