# encoding: utf-8
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

class Api::ContentViewsController < Api::ApiController
  respond_to :json
  before_filter :find_organization, :except => [:promote]
  before_filter :find_optional_environment, :only => [:index]
  before_filter :find_environment, :only => [:promote]
  before_filter :find_content_view, :only => [:show, :promote]
  before_filter :authorize

  def rules
    index_test   = lambda { ContentView.any_readable?(@organization) }
    show_test    = lambda { @view.readable? }
    promote_test = lambda { @view.promotable? }

    {
      :index   => index_test,
      :show    => show_test,
      :promote => promote_test
    }
  end

  api :GET, "/organizations/:organization_id/content_views", "List content views"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :environment_id, :identifier, :desc => "environment identifier",
    :required => false
  param :label, String, :desc => "content view label", :required => false
  def index
    if @environment
      ContentView.non_default.readable(@organization).
        joins(:content_view_environments).
        where("content_view_environments.environment_id = ?", @environment.id)
    else
      @content_views = ContentView.non_default.readable(@organization)
    end
    if params[:label].present?
      @content_views = @content_views.select {|cv| cv.label == params[:label]}
    end
    render :json => @content_views
  end

  api :GET, "/content_views/:id"
  param :id, :identifier, :desc => "content view id"
  def show
    render :json => @view
  end

  api :POST, "/content_views/:id/promote"
  param :id, :identifier, :desc => "content view id"
  param :environment_id, :identifier, :desc => "environment promoting to"
  def promote
    task = @view.promote_via_changeset(@environment)
    render :json => task, :status => 202
  end

  private

  def find_content_view
    @view = ContentView.non_default.find(params[:id])
  end

  def find_environment
    @environment = KTEnvironment.find(params[:environment_id])
  end

end
