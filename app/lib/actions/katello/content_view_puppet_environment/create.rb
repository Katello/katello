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
      class Create < Actions::EntryAction

        # rubocop:disable MethodLength
        def plan(puppet_environment, clone = false)
          puppet_environment.disable_auto_reindex!
          puppet_environment.save!
          action_subject(puppet_environment)
          plan_self

          puppet_path = puppet_environment.generate_puppet_path

          sequence do
            plan_action(Pulp::Repository::Create,
                        content_type: ::Katello::Repository::PUPPET_TYPE,
                        pulp_id: puppet_environment.pulp_id,
                        name: puppet_environment.name,
                        with_importer: true,
                        path: puppet_path)

            # when creating a clone, the following actions are handled by the
            # publish/promote process
            unless clone
              plan_action(Katello::Repository::MetadataGenerate, puppet_environment) if puppet_environment.environment
              plan_action(ElasticSearch::Reindex, puppet_environment)
            end
          end
        end

        def humanized_name
          _("Create")
        end

      end
    end
  end
end
