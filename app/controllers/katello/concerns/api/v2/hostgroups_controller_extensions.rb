#
# Copyright 2015 Red Hat, Inc.
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
  module Concerns
    module Api::V2::HostgroupsControllerExtensions
      extend ActiveSupport::Concern

      included do
        def_param_group :hostgroup do
          param :hostgroup, Hash, :required => true, :action_aware => true do
            param :name, String, :required => true
            param :parent_id, :number
            param :environment_id, :number
            param :operatingsystem_id, :number
            param :architecture_id, :number
            param :medium_id, :number
            param :ptable_id, :number
            param :puppet_ca_proxy_id, :number
            param :subnet_id, :number
            param :domain_id, :number
            param :realm_id, :number
            param :puppet_proxy_id, :number
            param :content_source_id, :number
            param :content_view_id, :number
            param :lifecycle_environment_id, :number
            param_group :taxonomies, ::Api::V2::BaseController
          end
        end

        api :POST, "/hostgroups/", N_("Create a host group")
        param_group :hostgroup, :as => :create
        def create
          @hostgroup = Hostgroup.new(params[:hostgroup])
          process_response @hostgroup.save
        end

        api :PUT, "/hostgroups/:id/", N_("Update a host group")
        param :id, :identifier, :required => true
        param_group :hostgroup
        def update
          process_response @hostgroup.update_attributes(params[:hostgroup])
        end
      end
    end
  end
end
