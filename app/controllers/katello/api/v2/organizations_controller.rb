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

    before_filter :local_find_taxonomy, :only => %w{repo_discover cancel_repo_discover
                                                    download_debug_certificate
                                                    redhat_provider update}

    resource_description do
      api_version 'v2'
      api_base_url "#{Katello.config.url_prefix}/api"
    end

    def local_find_taxonomy
      find_taxonomy
    end

    def rules
      edit_test   = lambda { @organization.editable? }
      redhat_provider_test   = lambda { @organization.redhat_provider.readable? }

      {
        :auto_attach_all_systems => edit_test,
        :repo_discover => edit_test,
        :cancel_repo_discover => edit_test,
        :download_debug_certificate => edit_test,
        :redhat_provider => redhat_provider_test
      }
    end

    api :GET, '/organizations', N_('List all organizations')
    param_group :search, Api::V2::ApiController
    def index
      @render_template = 'katello/api/v2/organizations/index'
      super
    end

    api :GET, '/organizations/:id', N_('Show organization')
    def show
      @render_template = 'katello/api/v2/organizations/show'
      super
    end

    api :PUT, '/organizations/:id', N_('Update organization')
    param_group :resource, ::Api::V2::TaxonomiesController
    param :description, String, :desc => N_("description")
    param :redhat_repository_url, String, :desc => N_("Redhat CDN url")
    def update
      if params.key?(:redhat_repository_url)
        @organization.redhat_provider.update_attributes!(:repository_url => params[:redhat_repository_url])
      end
      super
    end

    api :POST, '/organizations', N_('Create organization')
    param :name, String, :desc => N_("name"), :required => true
    param :label, String, :desc => N_("unique label")
    param :description, String, :desc => N_("description")
    def create
      super
    end

    api :DELETE, '/organizations/:id', N_('Delete an organization')
    def destroy
      process_response @organization.destroy, _("Deleted organization '%s'") % params[:id]
    end

    api :PUT, "/organizations/:id/repo_discover", N_("Discover Repositories")
    param :id, String, :desc => N_("organization id, label, or name")
    param :url, String, :desc => N_("base url to perform repo discovery on")
    def repo_discover
      fail _("url not defined.") if params[:url].blank?
      task = async_task(::Actions::Katello::Repository::Discover, params[:url])
      respond_for_async :resource => task
    end

    api :PUT, "/organizations/:label/cancel_repo_discover", N_("Cancel repository discovery")
    param :label, String, :desc => N_("Organization label")
    param :url, String, :desc => N_("base url to perform repo discovery on")
    def cancel_repo_discover
      # TODO: implement task canceling
      render :json => { message: "not implemented" }
    end

    api :GET, "/organizations/:label/download_debug_certificate", N_("Download a debug certificate")
    param :label, String, :desc => N_("Organization label")
    def download_debug_certificate
      pem = @organization.debug_cert
      data = "#{ pem[:key] }\n\n#{ pem[:cert] }"
      send_data data,
                :filename => "#{ @organization.name }-key-cert.pem",
                :type => "application/text"
    end

    api :POST, "/organizations/:id/autoattach_subscriptions", N_("Auto-attach available subscriptions to all systems within an organization. Asynchronous operation.")
    def autoattach_subscriptions
      async_job = @organization.auto_attach_all_systems
      respond_for_async :resource => async_job
    end

    api :GET, '/organizations/:id/redhat_provider', N_('List all :resource_id')
    def redhat_provider
      respond_for_show(:resource => @organization.redhat_provider,
                       :resource_name => "providers")
    end

    protected

    def action_permission
      if %w(download_debug_certificate redhat_provider repo_discover cancel_repo_discover).include?(params[:action])
        :edit
      else
        super
      end
    end

    def resource_identifying_attributes
      %w(id label)
    end

  end
end
