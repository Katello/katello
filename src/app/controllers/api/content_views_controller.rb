# encoding: utf-8
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

class Api::ContentViewsController < Api::ApiController
  respond_to :json
  before_filter :find_organization, :except => [:promote, :refresh]
  before_filter :find_optional_environment, :only => [:index, :show]
  before_filter :find_environment, :only => [:promote]
  before_filter :find_content_view, :only => [:show, :promote, :refresh]
  before_filter :authorize

  def rules
    index_test   = lambda { ContentView.any_readable?(@organization) }
    show_test    = lambda { @view.readable? }
    promote_test = lambda { @view.promotable? }
    refresh_test  = lambda { @view.content_view_definition.publishable? }

    {
      :index   => index_test,
      :show    => show_test,
      :promote => promote_test,
      :refresh => refresh_test
    }
  end

  api :GET, "/organizations/:organization_id/content_views", "List content views"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :environment_id, :identifier, :desc => "environment identifier",
    :required => false
  param :label, String, :desc => "content view label", :required => false
  param :name, String, :desc => "content view name", :required => false
  param :id, :identifier, :desc => "content view id", :required => false
  def index
    query_params.delete(:environment_id)
    query_params.delete(:organization_id)

    search = ContentView.non_default.where(query_params)
    @content_views = if @environment
      search.readable(@organization).in_environment(@environment)
    else
      search.readable(@organization)
    end
    render :json => @content_views
  end

  api :GET, "/organizations/:organization_id/content_views/:id"
  param :organization_id, :identifier, :desc => "organization identifier", :required => true
  param :id, :identifier, :desc => "content view id"
  param :environment_id, :identifier, :desc => "environment id", :required => false
  def show
    render :json => @view.as_json(:environment => @environment)
  end

  api :POST, "/content_views/:id/promote"
  param :id, :identifier, :desc => "content view id"
  param :environment_id, :identifier, :desc => "environment promoting to"
  def promote
    task = @view.promote_via_changeset(@environment)
    render :json => task, :status => 202
  end

  api :POST, "/content_views/:id/refresh"
  param :id, :identifer, :desc => "content view id"
  def refresh
    version = @view.refresh_view(:async => true)
    render :json => version.task_status, :status => 202
  end

  private

  def find_content_view
    @view = ContentView.non_default.find(params[:id])
  end

  def find_environment
    @environment = KTEnvironment.find(params[:environment_id])
  end

end
