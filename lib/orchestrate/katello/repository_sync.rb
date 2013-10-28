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

module Orchestrate
  module Katello
    class RepositorySync < Dynflow::Action

      include Helpers::RemoteAction
      include Helpers::Lock

      input_format do
        param :id, Integer
      end

      def plan(repo)
        lock(repo)
        plan_action(Pulp::RepositorySync, pulp_id: repo.pulp_id)
        plan_self(:id => repo.id)
      end

      def finalize
        repo = Repository.find(input[:id])
        repo.index_content
      end

    end
  end
end
