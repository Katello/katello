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
class Api::V1::SystemGroupErrataController < Api::V1::ApiController

  resource_description do
    description <<-DOC
      methods for handling erratas on system group level
    DOC

    param :organization_id, :identifier, :desc => "oranization identifier", :required => true
    param :system_group_id, :identifier, :desc => "system_group identifier", :required => true

    api_version 'v1'
    api_version 'v2'
  end

  respond_to :json

  before_filter :find_group, :only => [:index, :create]
  before_filter :authorize
  before_filter :require_errata, :only => [:create]

  def rules
    edit_systems = lambda { @group.systems_editable? }
    read_systems = lambda { @group.systems_readable? }
    {
        :create => edit_systems,
        :index  => read_systems
    }
  end

  api :GET, "/organizations/:organization_id/system_groups/:system_group_id/errata", "Get list of errata associated with the group"
  param :type, %w(bugfix enhancement security), :desc => "Filter errata by type", :required => false
  # TODO: when errata are enabled there has to be created rabl template for errata
  def index
    filter_type = params[:filter_type]

    if filter_type && filter_type != 'All'
      filter_type.downcase!
    else
      filter_type = nil
    end

    errata = @group.errata(filter_type)

    system_uuids = errata.flat_map{|e| e.applicable_consumers}.uniq
    system_hash = {}
    System.where(:uuid => system_uuids).select([:uuid, :name]).each do |sys|
      system_hash[sys.uuid] = sys
    end

    errata.each do |erratum|
      erratum.applicable_consumers = erratum.applicable_consumers.map{|uuid| {:name => system_hash[uuid].name, :uuid => uuid }}
    end

    respond :collection => errata
  end

  api :POST, "/organizations/:organization_id/system_groups/:system_group_id/errata", "Install errata remotely"
  param :errata_ids, Array, :desc => "List of errata ids to install", :required => true
  def create
    if params[:errata_ids]
      job = @group.install_errata(params[:errata_ids])
      respond_for_async :resource => job
    end
  end

  protected

  def find_group
    @group = SystemGroup.find(params[:system_group_id])
    fail HttpErrors::NotFound, _("Couldn't find system group '%s'") % params[:system_group_id] if @group.nil?
    @group
  end

  def require_errata
    if params.slice(:errata_ids).values.size != 1
      fail HttpErrors::BadRequest.new(_("One or more errata must be provided"))
    end
  end

end
end
