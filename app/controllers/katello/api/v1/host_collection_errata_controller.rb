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
class Api::V1::HostCollectionErrataController < Api::V1::ApiController

  resource_description do
    description <<-DOC
      methods for handling erratas on host collection level
    DOC

    param :organization_id, :number, :desc => "oranization identifier", :required => true
    param :host_collection_id, :identifier, :desc => "host_collection identifier", :required => true

    api_version 'v1'
    api_version 'v2'
  end

  respond_to :json

  before_filter :find_host_collection, :only => [:index, :create]
  before_filter :authorize
  before_filter :require_errata, :only => [:create]

  def rules
    edit_content_hosts = lambda { @host_collection.content_hosts_editable? }
    read_content_hosts = lambda { @host_collection.content_hosts_readable? }
    {
        :create => edit_content_hosts,
        :index  => read_content_hosts
    }
  end

  api :GET, "/organizations/:organization_id/host_collections/:host_collection_id/errata", "Get list of errata associated with the host collection"
  param :type, %w(bugfix enhancement security), :desc => "Filter errata by type", :required => false
  # TODO: when errata are enabled there has to be created rabl template for errata
  def index
    filter_type = params[:filter_type]

    if filter_type && filter_type != 'All'
      filter_type.downcase!
    else
      filter_type = nil
    end

    errata = @host_collection.errata(filter_type)

    content_host_uuids = errata.flat_map{|e| e.applicable_consumers}.uniq
    content_host_hash = {}
    System.where(:uuid => content_host_uuids).select([:uuid, :name]).each do |sys|
      content_host_hash[sys.uuid] = sys
    end

    errata.each do |erratum|
      erratum.applicable_consumers = erratum.applicable_consumers.map{|uuid| {:name => content_host_hash[uuid].name, :uuid => uuid }}
    end

    respond :collection => errata
  end

  api :POST, "/organizations/:organization_id/host_collections/:host_collection_id/errata", "Install errata remotely"
  param :errata_ids, Array, :desc => "List of errata ids to install", :required => true
  def create
    if params[:errata_ids]
      job = @host_collection.install_errata(params[:errata_ids])
      respond_for_async :resource => job
    end
  end

  protected

  def find_host_collection
    @host_collection = HostCollection.find(params[:host_collection_id])
    fail HttpErrors::NotFound, _("Couldn't find host collection '%s'") % params[:host_collection_id] if @host_collection.nil?
    @host_collection
  end

  def require_errata
    if params.slice(:errata_ids).values.size != 1
      fail HttpErrors::BadRequest.new(_("One or more errata must be provided"))
    end
  end

end
end
