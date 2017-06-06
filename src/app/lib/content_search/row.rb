#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class ContentSearch::Row
  include ContentSearch::Element
  display_attributes :id, :name, :cols, :data_type, :value, :parent_id, :comparable, :object_id
  alias :cells :cols
  alias :cells= :cols=

  def add_col(col)
    self.cols << col
  end
  alias :add_cell :add_col
end
