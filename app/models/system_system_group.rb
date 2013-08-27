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
#

class SystemSystemGroup < ActiveRecord::Base

  belongs_to :system
  belongs_to :system_group

  validate :validate_max_systems_not_exceeded
  validate :validate_system_environments

  def validate_max_systems_not_exceeded
    if new_record?
      system_group = SystemGroup.find(self.system_group_id)
      if (system_group) && (system_group.max_systems != SystemGroup::UNLIMITED_SYSTEMS) && (system_group.systems.size >= system_group.max_systems)
        errors.add :base, _("You cannot have more than %{max_systems} system(s) associated with system group '%{group}'.") % {:max_systems => system_group.max_systems, :group => system_group.name}
      end
    end
  end

  def validate_system_environments
    envs = system_group.environments
    if !envs.empty? && !envs.include?(system.environment)
      errors.add :base, _("System's environment not compatible with the group '%s'.") % system_group.name
    end
  end

end
