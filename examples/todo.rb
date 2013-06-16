$:.unshift File.expand_path('../../lib', __FILE__)

require 'sinatra'
require 'hexp'

Entry = Struct.new(:id, :description) do
  def to_hexp
    H[:span, {class: :entry}, description].attr('data-entry-id', self.id)
  end
end

class << Entry
  def store(entry)
    @counter ||= 0
    @entries ||= {}
    entry.id = (@counter+=1) unless entry.id
    @entries[entry.id] = entry
  end

  def find(id)
    @entries[id]
  end

  def all
    @entries.values || []
  end

  def delete(id)
    @entries.delete(id)
  end
end

class Layout
  def initialize(*contents)
    @contents = contents
  end

  def to_hexp
    H[:html, [
        H[:head],
        H[:body,  @contents ]
      ]
    ]
  end
end

class List
  def initialize(entries)
    @entries = entries
  end

  def to_hexp
    H[:ul,
      @entries.map do |entry|
        H[:li, entry]
      end
    ]
  end
end

class AddEntryForm
  def to_hexp
    H[:form, {method: 'POST', action: '/'}, [
        H[:input, {type: 'text', name: 'entry_description'}],
        H[:input, {type: 'submit'}, "Add"]
      ]
    ]
  end
end

class ListPage
  TITLE = 'Todo List'

  def to_hexp
    Layout.new(
      List.new(Entry.all),
      AddEntryForm.new
    ).to_hexp
      .rewrite(&method(:add_title))
      .rewrite(&method(:wrap_entry_forms))
  end

  def add_title(node, parent)
    if node.tag == :head
      H[:head, node.attributes, node.children + [title]]
    end
  end

  def wrap_entry_forms(node, parent)
    if node.attr('class') == 'entry'
      H[:form, {method: 'POST', action: "/#{node.attr('data-entry-id')}"}, [
          node,
          H[:input, type: 'hidden', name: '_method', value: 'DELETE'],
          H[:input, type: 'submit', value: '-']
        ]
      ]
    end
  end

  def title
    H[:title, TITLE]
  end
end

get '/' do
  ListPage.new.to_hexp.to_html
end

post '/' do
  @entry = Entry.new(nil, params['entry_description'])
  Entry.store(@entry)

  ListPage.new.to_hexp.to_html
end

delete '/:id' do
  Entry.delete params[:id].to_i

  ListPage.new.to_hexp.to_html
end
