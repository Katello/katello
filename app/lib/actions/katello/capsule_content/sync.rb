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
    module CapsuleContent
      class Sync < ::Actions::EntryAction
        def humanized_name
          _("Sychronize capsule content")
        end

        def plan(capsule_content, options = {})
          environment = options.fetch(:environment, nil)
          repository = options.fetch(:repository, nil)
          content_view = options.fetch(:content_view, nil)

          fail _("Action not allowed for the default capsule.") if capsule_content.default_capsule?

          repository_ids = get_repository_ids(capsule_content, environment, content_view, repository)
          unless repository_ids.blank?
            sequence do
              plan_action(ConfigureCapsule, capsule_content)
              plan_action(Pulp::Consumer::SyncNode,
                          consumer_uuid: capsule_content.consumer_uuid,
                          repo_ids: repository_ids)
            end
          end
        end

        def get_repository_ids(capsule, environment, content_view, repository)
          if environment
            repository_ids = capsule.pulp_repos([environment], content_view).map(&:pulp_id)
          elsif repository
            repository_ids = [repository.pulp_id]
            environment = repository.environment
          else
            repository_ids = capsule.pulp_repos.map(&:pulp_id)
          end

          if environment && !capsule.lifecycle_environments.include?(environment)
            fail _("Lifecycle environment '%{environment}' is not attached to this capsule.") % { :environment => environment.name }
          end

          repository_ids
        end
      end
    end
  end
end
