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

class UserOwnRole < Role

  use_index_of Role  if Katello.config.use_elasticsearch

  def self_role_for_user
    users.first
  end

  def create_or_update_default_system_registration_permission(organization, default_environment)
    if permissions.find_default_system_registration_permission
      permissions.update_default_system_registration_permission(default_environment)
    else
      permissions.create_default_system_registration_permission(organization, default_environment)
    end
  end
end
