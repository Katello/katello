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


class Api::V2::EnvironmentsController < Api::V1::EnvironmentsController

  include Api::V2::Rendering

  api :GET, "/organizations/:organization_id/environments/systems_registerable", "List environments that systems can be registered to"
  param :organization_id, :identifier, :desc => "organization identifier"
  def systems_registerable
    @environments = KTEnvironment.systems_registerable(@organization)
    respond_for_index :collection => @environments
  end

end
