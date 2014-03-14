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
  module Katello
    module ContentViewPuppetEnvironment
      class CloneContent < Actions::Base

        def plan(puppet_environment, module_ids_by_repoid)
          concurrence do
            module_ids_by_repoid.each_pair do |repo_id, module_ids|
              source_repo = ::Katello::ContentViewPuppetEnvironment.where(:pulp_id => repo_id).first ||
                ::Katello::Repository.where(:pulp_id => repo_id).first
              plan_copy(Pulp::Repository::CopyPuppetModule, source_repo, puppet_environment, clauses(module_ids))
            end
          end
        end

        def clauses(module_ids)
          { 'unit_id' => { "$in" => module_ids } }
        end

        def plan_copy(action_class, source_repo, target_repo, clauses = nil)
          plan_action(action_class,
                      source_pulp_id: source_repo.pulp_id,
                      target_pulp_id: target_repo.pulp_id,
                      clauses:        clauses)
        end
      end
    end
  end
end
