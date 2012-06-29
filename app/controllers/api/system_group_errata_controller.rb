# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'util/errata'

class Api::SystemGroupErrataController < Api::ApiController
  respond_to :json

  before_filter :find_group, :only => [:index, :create]
  before_filter :authorize
  before_filter :require_errata, :only => [:create]

  def rules
    edit_systems = lambda { @group.systems_editable? }
    read_systems = lambda { @group.systems_readable? }
    {
      :create => edit_systems,
      :index => read_systems
    }
  end

  # get the list of errata associated with the group
  def index
    errata = get_errata(params[:type])
    render :json => errata
  end

  # install errata remotely
  def create
    if params[:errata_ids]
      job = @group.install_errata(params[:errata_ids])
      render :json => job, :status => 202
    end
  end

  protected

  def find_group
    @group = SystemGroup.find(params[:system_group_id])
    raise HttpErrors::NotFound, _("Couldn't find system group '#{params[:system_group_id]}'") if @group.nil?
    @group
  end

  def require_errata
    if params.slice(:errata_ids).values.size != 1
      raise HttpErrors::BadRequest.new(_("One or more errata must be provided"))
    end
  end

  include Katello::Errata

  def get_errata filter_type="All"
    filter_type = filter_type || "All"

    errata_hash = {} # {id => erratum}

    # build a hash of all errata across all systems in the group
    @group.systems.each do |system|
      errata = system.errata
      errata.each do |erratum|
        if errata_hash.has_key?(erratum.id)
          # add the system to the existing erratum entry
          errata_hash[erratum.id][:systems].push(system.name)
        else
          # convert the erratum to a hash, add a systems array to the hash and add this system to it
          erratum_hash = erratum.as_json
          erratum_hash[:systems] ||= []
          erratum_hash[:systems] << system.name

          errata_hash[erratum.id] = erratum_hash
        end
      end
    end
    errata_list = errata_hash.values
    errata_list = filter_by_type(errata_list, filter_type)

    errata_list = errata_list.sort { |a,b|
      a["id"].downcase <=> b["id"].downcase
    }

    return errata_list
  end

end
