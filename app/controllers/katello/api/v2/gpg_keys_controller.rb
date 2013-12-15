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
  class Api::V2::GpgKeysController < Api::V2::ApiController

    before_filter :find_organization, :only => [:index]
    before_filter :authorize

    def rules
      index_test  = lambda { GpgKey.any_readable?(@organization) }

      {
        :index   => index_test
      }
    end

    api :GET, "/gpg_keys", "List gpg keys"
    param :organization_id, :identifier, :desc => "organization identifier"
    param_group :search, Api::V2::ApiController
    def index
      options = sort_params
      options[:load_records?] = true

      ids = GpgKey.readable(@organization).pluck(:id)

      options[:filters] = [
        {:terms => {:id => ids}}
      ]

      @search_service.model = GpgKey
      gpg_keys, total_count = @search_service.retrieve(params[:search], params[:offset], options)

      collection = {
        :results  => gpg_keys,
        :subtotal => total_count,
        :total    => @search_service.total_items
      }

      respond_for_index(:collection => collection)
    end

    # apipie docs are defined in v1 controller - they remain the same
    def show
      respond :resource => @gpg_key
    end

  end
end
