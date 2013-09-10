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

class Api::V2::SystemErrataController < Api::V2::ApiController

  before_filter :find_system, :only => [:apply]
  before_filter :authorize

  def rules
    {
      :apply => lambda { @system.editable? || User.consumer? }
    }
  end

  def apply
    task = @system.install_errata(params[:errata_ids])
    respond_for_show :template => 'system_task', :resource => task
  end

  private

  def find_system
    @system = System.first(:conditions => { :uuid => params[:system_id] })
    raise HttpErrors::NotFound, _("Couldn't find system '%s'") % params[:system_id] if @system.nil?
    @system
  end
end
