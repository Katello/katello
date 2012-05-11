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
#

class SystemSystemGroup < ActiveRecord::Base
  include Authorization

  belongs_to :system
  belongs_to :system_group

  validate :validate_max_systems_not_exceeded
  def validate_max_systems_not_exceeded
    if new_record?
      system_group = SystemGroup.find(self.system_group_id)
      if (system_group) and (system_group.max_systems != SystemGroup::UNLIMITED_SYSTEMS) and (system_group.systems.size >= system_group.max_systems)
        errors.add :base, _("You cannot have more than %s system(s) associated with system group '%s'.") % [system_group.max_systems, system_group.name]
      end
    end
  end
end
