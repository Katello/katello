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

class Api::V1::NoticesController < Api::V1::ApiController
  respond_to :json

  before_filter :find_notice, :only => [:show, :update, :destroy]
  before_filter :authorize

  def rules
    list_notices = lambda { true }

    {
        :index             => list_notices,
        :show              => lambda { true },
        :update            => lambda { true },
        :destroy           => lambda { true }
    }
  end

  def_param_group :notice do
    description "Notices"
    param :id, :identifier, :desc => "Notice uuid", :required => true

    api_version 'v1'
    api_version 'v2'
  end


  api :GET, "/notices", "List notices"
  param :search, String, :desc => "Filter notices by advanced search query"
  def index

    order = split_order(params[:order])
    query_string = params[:search]
    offset = params[:offset].to_i || 0
    filters = []

    filters << {:user_ids => [current_user.id]}

    options = {
        :filter => filters,
        :load_records? => false
    }
    if params[:paged]
      options[:page_size] = params[:page_size] || current_user.page_size
    end

    options[:sort_by] = params[:sort_by] || :created_at
    options[:sort_order] = params[:sort_order] || 'DESC'

    if params[:paged]
      options[:page_size] = params[:page_size] || current_user.page_size
    end

    items = Glue::ElasticSearch::Items.new(Notice)
    notices, total_count = items.retrieve(query_string, offset, options)

    if params[:paged]
      notices = {
        :results => notices,
        :subtotal => total_count,
        :total => items.total_items
      }
    end

    respond({ :collection => notices })
  end

  api :GET, "/notices/:id", "Show a notice"
  param :id, String, :desc => "ID of the notice", :required => true
  def show
    respond
  end

  api :PUT, "/notices/:id", "Update a notice"
  param :id, String, :desc => "ID of the notice", :required => true
  def update
    respond
  end

  api :DELETE, "/notices/:id", "Delete a notice"
  param :id, String, :desc => "ID of the notice", :required => true
  def destroy
    @notice.destroy
    respond
  end

  private

  def find_notice
    @notice = Notice.first(:conditions => { :id => params[:id] })
    raise HttpErrors::NotFound, _("Couldn't find notice '%s'") % params[:notice_id] if @notice.nil?
    @notice
  end

end
