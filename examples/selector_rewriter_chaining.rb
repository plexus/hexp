d=H[:div, %w(foo bar baz).map{|klz| [:p, class: klz]}]

#=> H[:div, [H[:p, {"class"=>"foo"}], H[:p, {"class"=>"bar"}], H[:p, {"class"=>"baz"}]]]

d.select {|node|node.class? 'bar'} #=> #<Hexp::Node::Selector>
  .wrap(:span)                     #=> #<Hexp::Node::Rewriter>
  .attr('data-x', '77')            #=> #<Hexp::Node::Rewriter>
  .wrap(:foo, 'hello' => 'jow')    #=> #<Hexp::Node::Rewriter>
  .attr('faz', 'foz').to_html(:include_doctype => false)

# <div>
# <p class="foo"></p>
# <foo hello="jow" faz="foz"><span data-x="77"><p class="bar"></p></span></foo><p class="baz"></p>
# </div>
