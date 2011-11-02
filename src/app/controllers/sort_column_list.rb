#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module SortColumnList

  # columns is a hash with keys being the two pane colunms and value is the arr attribute
  def sort_columns(columns, arr)
    field = params[:order].split(" ").first
    if (columns.keys.include?(field))
      # sort based on column name and push any nils to end of array
      arr.sort! { |a,b| (a.send(columns[field]) and b.send(columns[field])) ?
                       (a.send(columns[field]) <=> b.send(columns[field])) : (a ? -1 : 1) }
      arr.reverse! if params[:order].split(" ").last.downcase == "desc"
    end
  end

end
