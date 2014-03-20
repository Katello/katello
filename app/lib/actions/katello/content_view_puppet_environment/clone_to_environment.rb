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

      class CloneToEnvironment < Actions::Base

        def plan(version, environment)
          source = version.content_view_puppet_environments.archived.first
          clone = find_or_build_puppet_env(version, environment)

          sequence do
            if clone.new_record?
              plan_action(ContentViewPuppetEnvironment::Create, clone, true)
            else
              clone.content_view_version = version
              clone.save!
              plan_action(ContentViewPuppetEnvironment::Clear, clone)
            end

            plan_action(Pulp::Repository::CopyPuppetModule,
                        source_pulp_id: source.pulp_id,
                        target_pulp_id: clone.pulp_id,
                        criteria: nil)

            concurrence do
              plan_action(Katello::Repository::MetadataGenerate, clone)
              plan_action(ElasticSearch::ContentViewPuppetEnvironment::IndexContent, id: clone.id)
            end
          end
        end

        # The environment clone clone of the repository is the one
        # visible for the systems in the environment
        def find_or_build_puppet_env(version, environment)
          puppet_env = ::Katello::ContentViewPuppetEnvironment.in_content_view(version.content_view).
              in_environment(environment).scoped(:readonly => false).first

          unless puppet_env
            puppet_env = version.content_view.build_puppet_env(:environment => environment)
          end
          puppet_env
        end

      end
    end
  end
end
