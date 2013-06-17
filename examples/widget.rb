$:.unshift File.expand_path '../../lib', __FILE__

require 'hexp'
require 'virtus'
#require 'active_support/all'

class Widget
  include Virtus

  attribute :tag,  Symbol, default: :div
  attribute :data, Hash

  def to_hexp
    H[tag, html_attributes, widget]
  end

  def html_attributes
    Hash[data.map {|k,v| ["data-#{k}", v]}].merge(class: self.class.name.downcase + ' widget' )
  end

  def self.handlebars
    self.new(
      Hash[
        attribute_set
          .reject {|attribute| [:data, :tag].include?(attribute.name)    }
          .map    {|attribute| [attribute.name, "{{#{attribute.name}}}"] }
      ]
    ).to_hexp.to_html
  end
end


class Entry < Widget
  attribute :name, String
  attribute :date, String

  def widget
    [
      [:span, name],
      [:span, date]
    ]
  end
end


puts Entry.new(name: 'foo', date: '2013-06-17', data: {id: 17}).to_hexp.to_html
puts Entry.handlebars


# >> <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
# >> <div data-id="17" class="entry widget">
# >> <span>foo</span><span>2013-06-17</span>
# >> </div>
# >> <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
# >> <div class="entry widget">
# >> <span>{{name}}</span><span>{{date}}</span>
# >> </div>
