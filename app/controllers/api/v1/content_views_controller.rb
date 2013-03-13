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

class Api::V1::ContentViewsController < Api::V1::ApiController

  before_filter :find_environment, :only => [:promote]
  before_filter :find_environment_or_organization, :only => [:index]
  before_filter :find_content_view, :only => [:show, :promote, :refresh, :destroy]
  before_filter :authorize

  def rules
    index_test   = lambda { ContentView.any_readable?(@organization) }
    show_test    = lambda { @view.readable? }
    promote_test = lambda { @view.promotable? }
    refresh_test = lambda { @view.content_view_definition.publishable? }
    delete_test  = lambda { @view.content_view_definition.publishable? }

    {
      :index   => index_test,
      :show    => show_test,
      :promote => promote_test,
      :refresh => refresh_test,
      :destroy => delete_test
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
    respond :collection => @content_views
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
    respond_for_async :resource => task
  end

  api :POST, "/content_views/:id/refresh"
  param :id, :identifer, :desc => "content view id"
  def refresh
    version = @view.refresh_view(:async => true)
    respond_for_async :resource => version.task_status
  end

  api :DELETE, "/content_views/:id"
  param :id, :identifer, :desc => "content view id"
  def destroy
    @view.destroy
    if @view.destroyed?
      render :text => _("Deleted content view [ %s ]") % @view.name , :status => 200
    else
      raise HttpErrors::InternalError, _("Error while deleting content view [ %{name} ]: %{error}") %
        {:name => @view.name, :error => @view.errors.full_messages}
    end
  end

  private

  def find_content_view
    @view = ContentView.non_default.find(params[:id])
  end

  def find_environment
    @environment = KTEnvironment.find_by_id(params[:environment_id])
    raise HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
    @organization ||= @environment.organization
  end

  def find_environment_or_organization
    if params[:environment_id]
      @environment = KTEnvironment.find_by_id(params[:environment_id])
      raise HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
      @organization ||= @environment.organization
    else
      @organization = get_organization params[:organization_id]
      raise HttpErrors::NotFound, _("Couldn't find organization '%s'") % params[:organization_id] if @organization.nil?
    end
  end

end
