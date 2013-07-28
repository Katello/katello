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
  class Api::V2::ActivationKeysController < Api::V1::ActivationKeysController

    include Api::V2::Rendering

    resource_description do
      api_version 'v2'
    end

    api :GET, "/environments/:environment_id/activation_keys", "List activation keys"
    api :GET, "/organizations/:organization_id/activation_keys", "List activation keys"
    param :name, :identifier, :desc => "lists by activation key name"
    def index
      @activation_keys = ActivationKey.where(query_params.slice(:name, :organization_id, :environment_id))
      respond
    end

    api :POST, "/activation_keys/:id/system_groups"
    def add_system_groups
      super
    end

    api :DELETE, "/activation_keys/:id/system_groups"
    def remove_system_groups
      super
    end

  end
end
