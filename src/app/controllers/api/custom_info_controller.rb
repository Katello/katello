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
    render :json => @informable.custom_info.create!(params.slice(:keyname, :value)).to_json
  end

  def index
    render :json => @informable.custom_info.to_json
  end

  def show
    render :json => @custom_informatios.to_json
  end

  def update
    @custom_informatios.update_attributes!(:value => params[:value])
    render :json => @custom_informatios.to_json
  end

  def destroy
    @custom_informatios.destroy
    render :text => _("Deleted custom info '%s'") % params[:keyname], :status => 204
  end

  private

  def find_informable
    @klass = params[:informable_type].classify.constantize
    @informable = @klass.find(params[:informable_id])
    @informable
  end

  def find_custom_info
    @custom_informatios = @informable.custom_info.find_by_keyname(params[:keyname])
    raise HttpErrors::NotFound, _("Couldn't find custom info") if @custom_informatios.nil?
    @custom_informatios
  end

end
