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
  attr_accessor :id, :name, :cells, :data_type, :value, :parent_id, :comparable

  def initialize(options)
    options.each do |key, value|
      send("#{key}=", value)
    end
  end

  def as_json(options = {})
    {
     :id => self.id,
     :name => self.name,
     :cols => self.cells,
     :data_type => self.data_type,
     :value => self.value
    }
  end

end
