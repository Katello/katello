module Katello
  module SortColumnList
    # columns is a hash with keys being the two pane colunms and value is the arr attribute
    def sort_columns(columns, arr)
      field = params[:order].split(" ").first
      if columns.keys.include?(field)
        # sort based on column name and push any nils to end of array
        arr.sort! do |a, b|
          if a.send(columns[field]) && b.send(columns[field])
            a.send(columns[field]) <=> b.send(columns[field])
          else
            (a ? -1 : 1)
          end
        end
        arr.reverse! if params[:order].split(" ").last.downcase == "desc"
      end
    end
  end
end
