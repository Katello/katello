#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class Api::CustomInfoController < Api::ApiController
  respond_to :json

  before_filter :find_informable
  before_filter :find_custom_info, :only => [:show, :update, :destroy]
  before_filter :authorize


  def rules
    edit_custom_info = lambda { @informable.editable? }
    view_custom_info = lambda { @informable.readable? }

    {
        :index => view_custom_info,
        :show => view_custom_info,
        :create => edit_custom_info,
        :update => edit_custom_info,
        :destroy => edit_custom_info
    }
  end

  def create
    response = @informable.custom_info.create!(package_args(params))
    render :json => response.to_json
  end

  def index
    render :json => @informable.custom_info.to_json
  end

  def show
    render :json => @single_custom_info.to_json
  end

  def update
    value = params[:value].strip
    @single_custom_info.update_attributes!(:value => value)
    render :text => @single_custom_info.value
  end

  def destroy
    @single_custom_info.destroy
    render :text => _("Deleted custom info '%s'") % params[:keyname]
  end

  private

  def package_args(args)
    return args.slice(:keyname, :value).delete_if { |k, v| v.nil? }.inject({}) { |h, (k, v)| h[k] = v.strip; h }
  end

  def find_informable
    @informable = CustomInfo.find_informable(params[:informable_type], params[:informable_id])
  end

  def find_custom_info
    keyname = params[:keyname].strip
    @single_custom_info = CustomInfo.find_by_informable_keyname(@informable, keyname)
    if @single_custom_info.nil?
      raise HttpErrors::NotFound, _("Couldn't find custom info with keyname '%s'") % params[:keyname]
    end
  end

end
