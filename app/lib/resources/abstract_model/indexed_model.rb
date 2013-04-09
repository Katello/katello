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

module Resources::AbstractModel::IndexedModel

  def self.included(base)
    base.class_eval do
      include ::Ext::IndexedModel
    end
  end

  def update_index
    if self.destroyed?
      index.remove self
    else
      response = index.store( self, {:percolate => percolator} )
      self.id ||= response['_id'] if self.respond_to?(:id=)
      self._index = response['_index'] if self.respond_to?(:_index=)
      self._type = response['_type'] if self.respond_to?(:_type=)
      self._version = response['_version'] if self.respond_to?(:_version=)
      self.matches = response['matches'] if self.respond_to?(:matches=)
      self
    end
  end


end
