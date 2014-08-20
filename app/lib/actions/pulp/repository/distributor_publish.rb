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

module Actions
  module Pulp
    module Repository
      class DistributorPublish < Pulp::AbstractAsyncTask

        input_format do
          param :pulp_id
          param :distributor_type_id
          param :source_pulp_id
          param :dependency
        end

        def invoke_external_task
          pulp_extensions.repository.
              publish(input[:pulp_id],
                      distributor_id(input[:pulp_id], input[:distributor_type_id]),
                      distributor_config)
        end

        def distributor_id(pulp_id, distributor_type_id)
          distributor = repo(pulp_id)["distributors"].find do |dist|
            dist["distributor_type_id"] == distributor_type_id
          end
          distributor['id']
        end

        def distributor_config
          if input[:distributor_type_id] == Runcible::Models::YumCloneDistributor.type_id
            { override_config: { source_repo_id: input[:source_pulp_id],
                                 source_distributor_id: source_distributor_id} }
          end
        end

        def source_distributor_id
          distributor_id(input[:source_pulp_id], Runcible::Models::YumDistributor.type_id)
        end

        def repo(pulp_id)
          pulp_extensions.repository.retrieve_with_details(pulp_id)
        end

      end
    end
  end
end
