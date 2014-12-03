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
    module Consumer
      class AbstractNodeDistributorTask <  Pulp::AbstractAsyncTask
        def invoke_external_task
          fail NotImplementedError
        end

        protected

        def distributor
          @distributor ||= repo_details['distributors'].find do |distributor|
            distributor["distributor_type_id"] == Runcible::Models::NodesHttpDistributor.type_id
          end
          unless @distributor
            fail "Could not find node distributor for repository %s" % input[:repo_id]
          end
          @distributor
        end

        def repo_details
          pulp_extensions.repository.retrieve_with_details(input[:repo_id])
        end
      end
    end
  end
end
