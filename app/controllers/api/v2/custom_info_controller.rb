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


class Api::V2::CustomInfoController < Api::V1::CustomInfoController

  include Api::V2::Rendering

  resource_description do
    api_version "v2"
  end

  def_param_group :informable_identifier do
    param :informable_type, String, :desc => "name of the resource", :required => true
    param :informable_id, :identifier, :desc => "resource identifier", :required => true
  end

  def_param_group :custom_info do
    param :custom_info, Hash, :required => true, :action_aware => true do
      param :keyname, String, :required => true
      param :value, String, :required => true
    end
  end

  api :POST, "/custom_info/:informable_type/:informable_id", "Create custom info"
  param :informable_type, String, :desc => "name of the resource", :required => true
  param :informable_id, :identifier, :desc => "resource identifier", :required => true
  param :custom_info, Hash, :required => true, :action_aware => true do
    param :keyname, String, :required => true
    param :value, String, :required => true
  end
  def create
    respond :resource => @informable.custom_info.create!(params[:custom_info])
  end

  api :PUT, "/custom_info/:informable_type/:informable_id/:keyname", "Update custom info"
  param_group :informable_identifier
  param :keyname, String, :desc => "Custom info key", :required => true
  param :custom_info, Hash, :required => true, :action_aware => true do
    param :value, String, :required => true
  end
  def update
    @single_custom_info.update_attributes!(params[:custom_info].slice(:value))
    respond :resource => @single_custom_info
  end

end
