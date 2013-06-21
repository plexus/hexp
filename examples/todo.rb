$:.unshift File.expand_path('../../lib', __FILE__)
$:.unshift File.expand_path('../../examples', __FILE__)

require 'sinatra'
require 'hexp'
require 'widget'

class EntryStore
  def self.store(entry)
    @counter ||= 0
    @entries ||= {}
    entry.id = (@counter+=1) unless entry.id
    @entries[entry.id] = entry
  end

  def self.find(id)
    @entries[id]
  end

  def self.all
    @entries ||= {}
    @entries.values || []
  end

  def self.delete(id)
    @entries.delete(id)
  end
end

class Entry < Widget(:span)
  attribute :id, Integer
  attribute :description, String

  def widget
    [ description ]
  end
end

class EntryList
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

class Layout
  include Hexp

  def initialize(*contents)
    @contents = contents
    p @contents
  end

  def to_hexp
    H[:html, [
        H[:head],
        H[:body,  @contents ]
      ]
    ]
  end
end

class ListPage
  include Hexp
  TITLE = 'Todo List'

  def to_hexp
    hexp = Layout.new(
      EntryList.new(EntryStore.all),
      AddEntryForm.new
    )
    hexp = add_title(hexp)
    hexp = wrap_entry_forms(hexp)
  end

  def title
    H[:title, TITLE]
  end

  def add_title(tree)
    tree.rewrite do |node|
      if node.tag == :head
        H[:head, node.attributes, node.children + [title]]
      end
    end
  end

  def wrap_entry_forms(tree)
    tree.rewrite do |node|
      if node.class? 'entry'
        H[:form, {method: 'POST', action: "/#{node.attr('data-id')}"}, [
            node,
            H[:input, type: 'hidden', name: '_method', value: 'DELETE'],
            H[:input, type: 'submit', value: '-']
          ]
        ]
      end
    end
  end
end

get '/' do
  ListPage.new.to_html
end

post '/' do
  @entry = Entry.new(description: params['entry_description'])
  EntryStore.store(@entry)

  ListPage.new.to_html
end

delete '/:id' do
  EntryStore.delete params[:id].to_i

  ListPage.new.to_html
end

get '/handlebars' do
  Entry.handlebars.to_html
end
