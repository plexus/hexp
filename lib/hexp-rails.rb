require 'hexp'
require 'hexp/core_ext/nil' # Opt-in to NilClass#to_hexp

module Hexp
  # Transparently use Hexp nodes in templates
  class Node
    def to_s
      to_html.html_safe
    end
  end

  class List
    def to_s
      to_html.html_safe
    end
  end

  class TextNode
    def to_s
      to_html.html_safe
    end
  end

  # Honor ActiveSupport::SafeBuffer's "html_safe" flag
  class Unparser
    alias orig_escape_text escape_text
    def escape_text(text)
      text.html_safe? ? text : orig_escape_text(text)
    end
  end
end
