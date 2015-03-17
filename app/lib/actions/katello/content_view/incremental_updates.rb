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
        include Helpers::Presenter

        def plan(version_environments, composite_version_environments, content, dep_solve, systems, description)
          old_new_version_map = {}
          output_for_version_ids = []

          sequence do
            concurrence do
              version_environments.each do |version_environment|
                version = version_environment[:content_view_version]
                if version.content_view.composite?
                  fail _("Cannot perform an incremental update on a Composite Content View Version (%{name} version version %{version}") %
                    {:name => version.content_view.name, :version => version.version}
                end

                action = plan_action(ContentViewVersion::IncrementalUpdate, version,
                            version_environment[:environments], :resolve_dependencies => dep_solve, :content => content, :description => description)
                old_new_version_map[version] = action.new_content_view_version
                output_for_version_ids << {:version_id => action.new_content_view_version.id, :output => action.output}
              end
            end

            if composite_version_environments.any?
              handle_composites(old_new_version_map, composite_version_environments, output_for_version_ids, description, content[:puppet_module_ids])
            end

            if systems.any? && !content[:errata_ids].blank?
              plan_action(::Actions::BulkAction, ::Actions::Katello::System::Erratum::ApplicableErrataInstall, systems, content[:errata_ids])
            end
            plan_self(:version_outputs => output_for_version_ids)
          end
        end

        def handle_composites(old_new_version_map, composite_version_environments, output_for_version_ids, description, puppet_module_ids)
          concurrence do
            composite_version_environments.each do |version_environment|
              composite_version = version_environment[:content_view_version]
              environments = version_environment[:environments]
              new_components = composite_version.components.map { |component| old_new_version_map[component] }.compact

              if new_components.empty?
                fail _("Incremental update specified for composite %{name} version %{version}, but no components updated.")  %
                      {:name => composite_version.content_view.name, :version => composite_version.version}
              end

              action = plan_action(ContentViewVersion::IncrementalUpdate, composite_version, environments,
                                   :new_components => new_components, :description => description,
                                                           :content => {:puppet_module_ids => puppet_module_ids})
              output_for_version_ids << {:version_id => action.new_content_view_version.id, :output => action.output}
            end
          end
        end

        def run
          output[:changed_content] = input[:version_outputs].map do |version_output|
            {
              :content_view_version => {:id => version_output[:version_id]},
              :added_units => version_output[:output][:added_units]
            }
          end
        end

        def humanized_name
          _("Incremental Update")
        end

        def presenter
          Presenters::IncrementalUpdatesPresenter.new(self)
        end
      end
    end
  end
end
