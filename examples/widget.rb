$:.unshift File.expand_path '../../lib', __FILE__

require 'hexp'
require 'virtus'

class Widget
  include Hexp
  include Virtus

  attribute :tag,  Symbol, default: :div
  attribute :data, Hash

  def to_hexp
    H[tag, html_attributes, widget]
  end

  def html_attributes
    attrs = Hash[data.map {|k,v| ["data-#{k}", v]}].merge(class: [self.class.widget_name, 'widget']*' ' )
    if attribute_set.any?{|attribute| attribute.name == :id} && self.id
      attrs['data-id'] = self.id
    end
    attrs
  end

  def self.widget_name
    self.name.downcase
  end

  def self.handlebars
    H[:script, {:type => 'application/x-handlebars-template', :id => widget_name+'-template'},
      self.new(
        Hash[
          attribute_set
            .reject {|attribute| [:data, :tag].include?(attribute.name)    }
            .map    {|attribute| [attribute.name, "{{#{attribute.name}}}"] }
        ]
      )
    ]
  end
end

def Widget(tag)
  Class.new(Widget) do
    attribute :tag, Symbol, default: tag
  end
end


# class Entry < Widget(:p)
#   attribute :name, String
#   attribute :date, String # !> assigned but unused variable - type

#   def widget
#     [
#       [:span, name],
#       [:span, date]
#     ]
#   end
# end

# puts Entry.new(name: 'foo', date: '2013-06-17', data: {id: 17}).to_html
# puts
# puts Entry.handlebars.to_html
 # !> instance variable @default not initialized
