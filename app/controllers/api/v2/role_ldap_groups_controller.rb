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

class Api::V2::RoleLdapGroupsController < Api::V1::RoleLdapGroupsController

  include Api::V2::Rendering

  resource_description do
    api_version "v2"
  end

  api :POST, "/roles/:role_id/ldap_groups", "Add group to list of LDAP groups associated with the role"
  param :ldap_group, Hash, :required => true, :action_aware => true do
    param :name, String, :desc => "name of the LDAP group", :required => true
  end
  def create
    @role.add_ldap_group(params[:ldap_group][:name])
    respond
  end

end

