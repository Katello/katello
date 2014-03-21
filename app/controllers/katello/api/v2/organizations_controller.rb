#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  class Api::V2::OrganizationsController < ::Api::V2::OrganizationsController

    include Api::V2::Rendering
    include ForemanTasks::Triggers

    before_filter :local_find_taxonomy, :only => %w{repo_discover cancel_repo_discover}

    resource_description do
      api_version 'v2'
      api_base_url "#{Katello.config.url_prefix}/api"
    end

    def local_find_taxonomy
      find_taxonomy
    end

    def rules
      edit_test   = lambda { @organization.editable? }

      {
        :auto_attach_all_systems => edit_test,
        :repo_discover => edit_test,
        :cancel_repo_discover => edit_test
      }
    end

    api :GET, '/organizations', 'List all :resource_id'
    param_group :search, Api::V2::ApiController
    def index
      @render_template = 'katello/api/v2/organizations/index'
      super
    end

    api :GET, '/organizations/:id', 'Show organization'
    def show
      @render_template = 'katello/api/v2/organizations/show'
      super
    end

    api :PUT, '/organizations/:id', 'Update organization'
    param_group :resource, ::Api::V2::TaxonomiesController
    param :description, String, :desc => "description"
    def update
      super
    end

    api :POST, '/organizations', 'Create organization'
    param :name, String, :desc => "name", :required => true
    param :label, String, :desc => "unique label"
    param :description, String, :desc => "description"
    def create
      super
    end

    api :PUT, "/organizations/:id/repo_discover", "Discover Repositories"
    param :id, String, :desc => "organization id, label, or name"
    param :url, String, :desc => "base url to perform repo discovery on"
    def repo_discover
      fail _("url not defined.") if params[:url].blank?
      task = async_task(::Actions::Katello::Repository::Discover, params[:url])
      respond_for_async :resource => task
    end

    api :PUT, "/organizations/:label/cancel_repo_discover", "Cancel repository discovery"
    param :label, String, :desc => "Organization label"
    param :url, String, :desc => "base url to perform repo discovery on"
    def cancel_repo_discover
      # TODO: implement task canceling
      render :json => { message: "not implemented" }
    end

    api :POST, "/organizations/:id/autoattach_subscriptions", "Auto-attach available subscriptions to all systems within an organization. Asynchronous operation."
    def autoattach_subscriptions
      async_job = @organization.auto_attach_all_systems
      respond_for_async :resource => async_job
    end

    protected

    def resource_identifying_attributes
      %w(id label)
    end

  end
end
