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

require 'rest_client'

class Api::RoleLdapGroupsController < Api::ApiController

  before_filter :find_role
  before_filter :authorize

  def rules
    index_test = lambda{Role.any_readable?}
    edit_test = lambda{Role.editable?}
    {
      :index => index_test,
      :create => edit_test,
      :destroy => edit_test,
    }
  end

  def create
    @role.add_ldap_group(params[:name])
    render :text => _("Added LDAP group '%s'") % params[:name], :status => 200
  end

  def destroy
    @role.remove_ldap_group(params[:id])
    render :text => _("Removed LDAP group '%s'") % params[:id], :status => 200
  end

  def index
    render :json => @role.ldap_group_roles.where(query_params).to_json()
  end

  private

  def find_role
    @role = Role.find(params[:role_id])
    raise HttpErrors::NotFound, _("Couldn't find user role '%s'") % params[:role_id] if @role.nil?
    @role 
  end

end
