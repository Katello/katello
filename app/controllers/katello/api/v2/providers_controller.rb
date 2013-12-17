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

module Katello
class Api::V2::ProvidersController < Api::V2::ApiController

  before_filter :find_organization, :only => [:index, :create]
  before_filter :find_provider, :only => [:discovery, :update, :delete_manifest,
                                          :refresh_manifest, :show]
  before_filter :authorize

  def_param_group :provider do
    param :name, String, :desc => "Provider name", :required => true
  end

  def rules
    index_test  = lambda { Provider.any_readable?(@organization) }
    create_test = lambda { @organization.nil? ? true : Provider.creatable?(@organization) }
    show_test = lambda { @provider.readable? }
    edit_test = lambda { @provider.editable? }

    {
      :index                    => index_test,
      :create                   => create_test,
      :show                     => show_test,
      :update                   => edit_test,
      :delete_manifest          => edit_test,
      :refresh_manifest         => edit_test
    }
  end

  def param_rules
    {
      :create => [:name, :organization_id, :provider]
    }
  end

  api :GET, "/providers", "List providers"
  param_group :search, Api::V2::ApiController
  param :provider_type, String, "Filter providers by type ('Custom' or 'Red Hat')"
  def index
    options = sort_params
    options[:load_records?] = true

    ids = Provider.readable(@organization).pluck(:id)

    options[:filters] = [
      {:term => {:organization_id => @organization.id}},
      {:terms => {:id => ids}}
    ]

    if params[:type].blank?
      options[:filters] << {:not => {:term => {:provider_type => Provider::REDHAT}}}
    else
      # TODO: Fix after github issue #3494
      #options[:filters] << {:term => {:provider_type => params[:provider_type]}}
    end

    @search_service.model = Provider
    providers, total_count = @search_service.retrieve(params[:search], params[:offset], options)

    collection = {
      :results  => providers,
      :subtotal => total_count,
      :total    => @search_service.total_items
    }

    respond_for_index :collection => collection
  end

  api :POST, "/providers", "Create a provider"
  param_group :provider
  def create
    provider = Provider.create!(provider_params) do |p|
      p.organization  = @organization
      p.provider_type ||= Provider::CUSTOM
    end
    respond_for_show(:resource => provider)
  end

  api :PUT, "/providers/:id", "Update the provider"
  param :id, :number, :desc => "Provider identifier", :required => true
  param :repository_url, String, :desc => "Provider repository url"
  def update
    @provider.repository_url = params[:repository_url] unless params[:repository_url].blank?
    @provider.save!

    respond_for_show(:resource => @provider)
  end

  api :GET, "/providers/:id", "Get a provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  def show
    respond_for_show(:resource => @provider)
  end

  api :POST, "/providers/:id/delete_manifest", "Delete manifest from Red Hat provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  def delete_manifest
    if @provider.yum_repo?
      fail HttpErrors::BadRequest, _("Manifests cannot be deleted for a custom provider.")
    end

    @provider.delete_manifest
    respond_for_status :message => _("Manifest deleted")
  end

  api :POST, "/providers/:id/refresh_manifest", "Refresh previously imported manifest for Red Hat provider"
  param :id, :number, :desc => "Provider numeric identifier", :required => true
  def refresh_manifest
    if @provider.yum_repo?
      fail HttpErrors::BadRequest, _("Manifests cannot be refreshed for a custom provider.")
    end

    details  = @provider.organization.owner_details
    upstream = details['upstreamConsumer'].blank? ? {} : details['upstreamConsumer']
    @provider.refresh_manifest(upstream, :async => true, :notify => false)
    respond_for_async :resource => @provider.manifest_task
  end

  private

    def find_provider
      @provider = Provider.find(params[:id])
      @organization ||= @provider.organization
      fail HttpErrors::NotFound, _("Couldn't find provider '%s'") % params[:id] if @provider.nil?
    end

    def provider_params
      params.slice(:name)
    end

end
end
