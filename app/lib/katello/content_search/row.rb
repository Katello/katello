module Katello
  class ContentSearch::Row
    include ContentSearch::Element
    display_attributes :id, :name, :cols, :data_type, :value, :parent_id, :comparable, :object_id
    alias_method :cells, :cols
    alias_method :cells=, :cols=

    def add_col(col)
      self.cols << col
    end
    alias_method :add_cell, :add_col
  end
end
