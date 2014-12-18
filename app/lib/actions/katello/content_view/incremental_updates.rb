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
      class IncrementalUpdates < Actions::EntryAction
        def plan(version_environments, content, dep_solve, propagate_composites, description)
          old_new_version_map = {}
          sequence do
            concurrence do
              version_environments.each do |version_environment|
                action = plan_action(ContentViewVersion::IncrementalUpdate, version_environment[:content_view_version],
                            version_environment[:environments], :resolve_dependencies => dep_solve, :content => content, :description => description)
                old_new_version_map[version_environment[:content_view_version]] = action.new_content_view_version
              end
            end
            handle_composites(old_new_version_map, description, content[:puppet_module_ids]) if propagate_composites
          end
        end

        def handle_composites(old_new_version_map, description, puppet_module_ids)
          composite_version_map = {}
          old_new_version_map.each do |old_version, new_version|
            old_version.composites.each do |composite|
              if composite.environments.any?
                composite_version_map[composite] ||= []
                composite_version_map[composite] << new_version
              end
            end
          end

          concurrence do
            composite_version_map.each do |composite_version, new_components|
              plan_action(ContentViewVersion::IncrementalUpdate, composite_version,
                          composite_version.environments, :new_components => new_components, :description => description,
                                                           :content => {:puppet_module_ids => puppet_module_ids})
            end
          end
        end

        def humanized_name
          _("Incremental Update")
        end
      end
    end
  end
end
