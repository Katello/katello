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
  include CustomInfoHelper
  respond_to :json

  before_filter :find_informable
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
    raise HttpErrors::BadRequest, _("A Custom Info keyname must be provided") if params[:keyname].nil?
    raise HttpErrors::BadRequest, _("A Custom Info value must be provided") if params[:value].nil?
    args = params.slice(:keyname, :value)
    create_response = @informable.custom_info.create(args)
    render :json => consolidate([create_response]).to_json
  end

  def index
    index_response = consolidate(@informable.custom_info)
    render :json => index_response.to_json
  end

  def show
    info_to_show = @informable.custom_info.where(:keyname => params[:keyname])
    raise HttpErrors::NotFound,  _("Couldn't find Custom Info matching that criteria") if info_to_show.empty?
    show_response = consolidate(info_to_show)
    render :json => show_response.to_json
  end

  def update
    info_to_update = @informable.custom_info.where(:keyname => params[:keyname], :value => params[:current_value])
    raise HttpErrors::NotFound, _("Couldn't find Custom Info '%s: %s'") % [params[:keyname], params[:current_value]] if info_to_update.empty?
    info_to_update.first.update_attributes(:value => params[:value])
    render :json => consolidate(@informable.custom_info.where(:keyname => params[:keyname], :value => params[:value])).to_json
  end

  # When all args are supplied (keyname, value), only that one key-value pair will be destroyed.
  # If value is nil, then all pairs having keyname will be destroyed.
  # If both value and keyname are nil, then all custom info attached to the given informable will be destroyed.
  def destroy
    args = params.slice(:keyname, :value)
    unless args.empty?
      info_to_destroy = @informable.custom_info.where(args)
      raise HttpErrors::NotFound, _("Couldn't find Custom Info matching that criteria") if info_to_destroy.empty?
      destroy_response = info_to_destroy.each { |i| i.destroy }
    else
      destroy_response = @informable.custom_info.each { |i| i.destroy }
    end

    destroy_response = consolidate(destroy_response)
    render :json => destroy_response.to_json
  end

  private

  def find_informable
    raise HttpErrors::BadRequest, _("Please provide an informable_type and informable_id") if params[:informable_type].nil? or params[:informable_id].nil?
    @klass = params[:informable_type].classify.constantize
    @informable = @klass.find(params[:informable_id])
    @informable
  end

end
