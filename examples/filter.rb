$:.unshift('/home/arne/github/hexp/lib')
require 'hexp/h'

class X
  def to_hexp
    [:p, {class: 'foo'}, [
        [:br],
        'awesome',
        [:br]]]
  end
end

hexp =  H[:p, [
             [:div, {id: 'main'}, [
                   X.new,
                   X.new]],
             [:hr]]]


hexp = hexp.filter do |triplet|
  if triplet.attributes['class'] == 'foo'
    [[:p, 'foo coming up!'], triplet]
  else
    [triplet]
  end
end

puts hexp.pp

puts hexp.to_html

# >> H[:p, [
# >>   H[:div, {"id"=>"main"}, [
# >>       H[:p, [
# >>             "foo coming up!"]],
# >>       H[:p, {"class"=>"foo"}, [
# >>             H[:br],
# >>             "awesome",
# >>             H[:br]]],
# >>       H[:p, [
# >>             "foo coming up!"]],
# >>       H[:p, {"class"=>"foo"}, [
# >>             H[:br],
# >>             "awesome",
# >>             H[:br]]]]],
# >>   H[:hr]]]

# >> <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
# >> <p><div id="main">
# >> <p>foo coming up!</p>
# >> <p class="foo"><br>awesome<br></p>
# >> <p>foo coming up!</p>
# >> <p class="foo"><br>awesome<br></p>
# >> </div><hr></p>
