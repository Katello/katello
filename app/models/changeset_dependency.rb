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


class ChangesetDependency < ActiveRecord::Base
  include Authorization

  belongs_to :changeset, :inverse_of=>:dependencies
  belongs_to :product


  # returns list of virtual permission tags for the current user
  def self.list_tags
    select('id,display_name').all.collect { |m| VirtualTag.new(m.id, m.display_name) }
  end
end
