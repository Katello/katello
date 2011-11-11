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

module ProvidersHelper
  include SyncManagementHelper
  include SyncManagementHelper::RepoMethods

  def product_map
    @product_map ||= collect_repos(@provider.products.with_repos_only(current_organization.locker),
                                    current_organization.locker, true)
    @product_map
  end

  def can_enable_repo?
    @provider.editable?
  end

  def can_upload_rh_manifest?
    @provider.editable?
  end

  def can_edit_rh_provider?
    @provider.editable?
  end
end

