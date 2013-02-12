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
    render :json => CustomInfo._create(@informable, params[:keyname], params[:value]).to_json
  end

  def index
    render :json => CustomInfo._all(@informable).to_json
  end

  def show
    render :json => @single_custom_info.to_json
  end

  def update
    CustomInfo._update(@single_custom_info, params[:value])
    render :json => @single_custom_info.to_json
  end

  def destroy
    CustomInfo._destroy(@single_custom_info)
    render :text => _("Deleted custom info '%s'") % params[:keyname], :status => 204
  end

  private

  def find_informable
    @informable = CustomInfo._find_informable(params[:informable_type], params[:informable_id])
  end

  def find_custom_info
    @single_custom_info = CustomInfo._find(@informable, params[:keyname])
    raise HttpErrors::NotFound, _("Couldn't find custom info with keyname '%s'") % params[:keyname] if @single_custom_info.nil?
  end

end
