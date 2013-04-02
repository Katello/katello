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


class Api::V2::GpgKeysController < Api::V1::GpgKeysController

  include Api::V2::Rendering

  api :GET, "/organizations/:organization_id/gpg_keys", "List gpg keys"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :name, :identifier, :desc => "identifier of the gpg key"
  def index
    respond :collection => @organization.gpg_keys.where(params.slice(:name))
  end

  # apipie docs are defined in v1 controller - they remain the same
  def show
    respond :resource => @gpg_key
  end

end
