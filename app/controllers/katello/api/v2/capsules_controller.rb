#
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
  class Api::V2::CapsulesController < ::Api::V2::SmartProxiesController

    resource_description do
      api_base_url "#{Katello.config.url_prefix}/api"
    end

    api :GET, '/capsules', 'List all capsules'
    param_group :search, Api::V2::ApiController
    def index
      super
    end

    api :GET, '/capsules/:id', 'Show the capsule details'
    param :id, Integer, :desc => 'Id of the capsule', :required => true
    def show
      super
    end

    protected

    def resource_class
      SmartProxy
    end

    def resource_name
      :smart_proxy
    end

  end
end
