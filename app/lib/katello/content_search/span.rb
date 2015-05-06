# a span represents a collection of rows. usually these rows represent
# a container like a product or content view

module Katello
  class ContentSearch::Span
    include ContentSearch::Element
    display_attributes :rows
  end
end
