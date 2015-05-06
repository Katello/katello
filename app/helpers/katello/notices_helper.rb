module Katello
  module NoticesHelper
    def sortable(column, title)
      css_class = column == sort_column ? "active sortable #{sort_direction}" : nil
      direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
      link_to title, {:sort => column, :direction => direction}, :class => css_class
    end
  end
end
