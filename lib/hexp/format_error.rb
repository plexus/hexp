module Hexp
  # Raised when trying to stick things inside a Hexp where they don't belong
  class FormatError < StandardError
    # Create a new FormatError
    #
    # @api private
    #
    def initialize(msg = 'You have illegal contents in your Hexp')
      super
    end
  end
end
