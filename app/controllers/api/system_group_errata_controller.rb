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

class Api::SystemGroupErrataController < Api::ApiController
  respond_to :json

  before_filter :find_group, :only => [:create]
  before_filter :authorize
  before_filter :require_errata, :only => [:create]

  def rules
    edit_systems = lambda { @group.systems_editable? }
    {
      :create => edit_systems
    }
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
end
