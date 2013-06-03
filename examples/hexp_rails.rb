require 'hexp/h'

# Here's an example of using bare-bones Hexp together with Rails. A lot of this
# boilerplate would have to be wrapped/hidden, but it's a start.
#
# An interesting thing to note is that by overriding content_tag we can make other
# view helpers like link_to return Hexp objects rather than strings.

class UsersController < ApplicationController
  def index
    render :inline => UserIndexPage.new(User.all).to_html
  end
end

class UserIndexPage # < Hexp::Rails::Widget perhaps?
  include ActionView::Helpers::UrlHelper
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  delegate :to_html, to: :to_hexp
  attr_reader :users

  def initialize(users)
    @users = users
  end

  def to_hexp
    H[:div, [
        [:h1, "Listing users"],
        [:table, [
            [:thead, [
                [:tr, headings.map{|h| [:th, h]}]
              ]
            ],
            [:tbody, users.map do |user|
                H[:tr,
                  fields_for(user).map do |field|
                    [:td, [field]]
                  end
                ]
              end
            ]
          ]
        ]
      ]
    ]
  end

  def headings
    ['Name', 'Email', nil, nil, nil]
  end

  def fields_for(user)
    [ user.name,
      user.email,
      link_to('Show', user),
      link_to('Edit', edit_user_path(user)),
      link_to('Destroy', user, method: :delete, data: { confirm: 'Are you sure?' })
    ]
  end

  def content_tag(tag, content, attrs)
    H[tag, attrs, content]
  end

  # NullController to satisfy UrlHelper
  def controller
    Class.new do
      def respond_to?(*args)
        false
      end

      def method_missing(*args)
        return self
      end
    end.new
  end
end
