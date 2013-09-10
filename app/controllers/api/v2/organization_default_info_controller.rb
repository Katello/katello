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

class Api::V2::OrganizationDefaultInfoController < Api::V1::OrganizationDefaultInfoController

  include Api::V2::Rendering

  resource_description do
    api_version "v2"
  end

  def_param_group :informable_identifier do
    param :informable_type, String, :desc => "name of the resource", :required => true
    param :informable_id, :identifier, :desc => "resource identifier", :required => true
  end

  api :POST, '/organizations/:organization_id/default_info/:informable_type', "Create default info"
  param_group :informable_identifier
  param :default_info, Hash, :required => true do
    param :keyname, String, :required => true
  end
  def create
    inf_type = params[:informable_type]
    key_name = params[:default_info][:keyname]

    unless @organization.default_info[inf_type].include?(key_name)
      @organization.default_info[inf_type] << key_name
    end
    @organization.save!
    respond :resource => { :keyname => key_name }
  end

  # apipie docs are defined in v1 controller - they remain the same
  def destroy
    inf_type = params[:informable_type]
    @organization.default_info[inf_type].delete(params[:keyname])
    @organization.save!
    respond :resource => false
  end

  # apipie docs are defined in v1 controller - they remain the same
  def apply_to_all
    to_apply = @organization.default_info[params[:informable_type]].collect do |key|
      { :keyname => key }
    end
    systems  = CustomInfo.apply_to_set(@organization.systems, to_apply)
    respond_for_index :collection => systems
  end

end
