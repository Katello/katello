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

module Ext::PermissionTagCleanup
  def self.included(base)
    base.class_eval do
      if base == Organization
        after_destroy :delete_organization_associated_permission_tags
      else
        after_destroy :delete_associated_permission_tags
      end
    end
  end

  def delete_organization_associated_permission_tags
    PermissionTag.where(
        :permission_id =>
            Permission.where(:resource_type_id => ResourceType.where(:name => 'organizations'))
    ).where(:tag_id => id).delete_all
  end

  def delete_associated_permission_tags
    PermissionTag.where(
        :permission_id =>
            Permission.where(:organization_id => organization.id).where(
                :resource_type_id => ResourceType.where(:name => self.class.table_name)
            )
    ).where(:tag_id => id).delete_all
  end
end
