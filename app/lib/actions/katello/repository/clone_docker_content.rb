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
    module Repository
      class CloneDockerContent < Actions::Base
        def plan(source_repo, target_repo)
          sequence do
            plan_action(Pulp::Repository::CopyDockerImage,
                        source_pulp_id: source_repo.pulp_id,
                        target_pulp_id: target_repo.pulp_id)
            plan_action(Pulp::Repository::CopyDockerTag,
                        source_pulp_id: source_repo.pulp_id,
                        target_pulp_id: target_repo.pulp_id)
            plan_action(Katello::Repository::MetadataGenerate, target_repo)
            plan_action(ElasticSearch::Repository::IndexContent, id: target_repo.id)
          end
        end
      end
    end
  end
end
