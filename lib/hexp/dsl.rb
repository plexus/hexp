module Hexp
  module DSL
    [:tag, :attributes, :children, :attr, :rewrite, :to_html, :class?].each do |meth|
      define_method meth do |*args, &blk|
        to_hexp.public_send(meth, *args, &blk)
      end
    end
  end
end
