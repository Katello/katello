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

class Api::V1::CustomInfoController < Api::V1::ApiController
  respond_to :json

  before_filter :find_informable
  before_filter :find_custom_info, :only => [:show, :update, :destroy]
  before_filter :authorize


  def rules
    edit_custom_info = lambda { @informable.editable? }
    view_custom_info = lambda { @informable.readable? }

    {
        :index   => view_custom_info,
        :show    => view_custom_info,
        :create  => edit_custom_info,
        :update  => edit_custom_info,
        :destroy => edit_custom_info
    }
  end

  def_param_group :informable_identifier do
    param :informable_type, String, :desc => "name of the resource", :required => true
    param :informable_id, :identifier, :desc => "resource identifier", :required => true
  end

  api :POST, "/custom_info/:informable_type/:informable_id", "Create custom info"
  param_group :informable_identifier
  param :keyname, String, :required => true
  param :value, String, :required => true
  def create
    respond :resource => @informable.custom_info.create!(package_args(params))
  end

  api :GET, "/custom_info/:informable_type/:informable_id", "List custom info"
  param_group :informable_identifier
  def index
    respond :collection => @informable.custom_info
  end

  api :GET, "/custom_info/:informable_type/:informable_id/:keyname", "Show custom info"
  param_group :informable_identifier
  param :keyname, String, :desc => "Custom info key", :required => true
  def show
    respond :resource => @single_custom_info
  end

  api :PUT, "/custom_info/:informable_type/:informable_id/:keyname", "Update custom info"
  param_group :informable_identifier
  param :keyname, String, :desc => "Custom info key", :required => true
  param :value, String, :required => true
  def update
    value = params[:value].strip
    @single_custom_info.update_attributes!(:value => value)
    respond :resource => @single_custom_info.value
  end

  api :DELETE, "/custom_info/:informable_type/:informable_id/:keyname", "Delete custom info"
  param_group :informable_identifier
  param :keyname, String, :desc => "Custom info key", :required => true
  def destroy
    @single_custom_info.destroy
    respond :message => _("Deleted custom info '%s'") % params[:keyname], :resource => @single_custom_info
  end

  private

  def package_args(args)
    return args.slice(:keyname, :value).delete_if { |k, v| v.nil? }.inject({}) { |h, (k, v)| h[k] = v.strip; h }
  end

  def find_informable
    @informable = CustomInfo.find_informable(params[:informable_type], params[:informable_id])
  end

  def find_custom_info
    @single_custom_info = CustomInfo.find_by_informable_keyname(@informable, params[:keyname].strip)
    if @single_custom_info.nil?
      raise HttpErrors::NotFound, _("Couldn't find custom info with keyname '%s'") % params[:keyname]
    end
  end

end
