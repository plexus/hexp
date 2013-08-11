module Hexp
  module DSL
    [ :tag,
      :attributes,
      :children,
      :attr,
      :rewrite,
      :select,
      :to_html,
      :class?,
      :add_class,
      :add_child,
      :<<,
      :process,
      :%,
    ].each do |meth|
      define_method meth do |*args, &blk|
        to_hexp.public_send(meth, *args, &blk)
      end
    end
  end
end
