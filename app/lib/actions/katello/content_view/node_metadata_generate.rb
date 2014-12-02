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
    module ContentView
      class NodeMetadataGenerate < Actions::EntryAction
        def resource_locks
          :link
        end

        def humanized_name
          _("Generate and Synchronize Capsule Metadata for %s") % input[:environment_name]
        end

        def plan(content_view, environment)
          action_subject(content_view)

          concurrence do
            ::Katello::Repository.in_content_views([content_view]).in_environment(environment).each do |repo|
              plan_action(Katello::Repository::NodeMetadataGenerate, repo)
            end

            cv_puppet_env = ::Katello::ContentViewPuppetEnvironment.in_environment(environment).
                in_content_view(content_view).first
            plan_action(Katello::Repository::NodeMetadataGenerate, cv_puppet_env)
          end
          plan_self(:environment_name => environment.name)
        end
      end
    end
  end
end
