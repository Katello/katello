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


class Api::V2::SyncController < Api::V1::SyncController

  include Api::V2::Rendering

  resource_description do
    api_version "v2"
  end

  api :GET, "/providers/:provider_id/sync",  "Get status of repo synchronisation for given provider"
  api :GET, "/products/:product_id/sync", "Get status of repo synchronisation for given product"
  api :GET, "/repositories/:repository_id/sync", "Get status of synchronisation for given repository"
  def index
    super
  end

  api :POST, "/providers/:provider_id/sync", "Synchronize all provider's repositories"
  api :POST, "/products/:product_id/sync", "Synchronise all repositories for given product"
  api :POST, "/repositories/:repository_id/sync", "Synchronise repository"
  def create
    super
  end

  api :DELETE, "/providers/:provider_id/sync", "Cancel running synchronisation for given provider"
  api :DELETE, "/products/:product_id/sync", "Cancel running synchronisations for given product"
  api :DELETE, "/repositories/:repository_id/sync", "Cancel running synchronisation"
  def cancel
    super
  end

end
