# This file is *not* loaded by default. You have to explicitly require 'hexp/core_ext/nil'

class NilClass
  HEXP_NIL = Hexp::TextNode.new('')

  def to_hexp
    HEXP_NIL
  end
end
