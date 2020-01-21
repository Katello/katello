module Actions
  module Katello
    module ContentView
      class IncrementalUpdates < Actions::EntryAction
        include Helpers::Presenter

        def plan(version_environments, composite_version_environments, content, dep_solve, hosts, description)
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

            if hosts.any? && !content[:errata_ids].blank?
              errata = ::Katello::Erratum.with_identifiers(content[:errata_ids])
              hosts = hosts.where(:id => ::Katello::Host::ContentFacet.with_applicable_errata(errata).pluck(:host_id))
              plan_action(::Actions::BulkAction, ::Actions::Katello::Host::Erratum::ApplicableErrataInstall, hosts, :errata_ids => content[:errata_ids])
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
                fail _("Incremental update specified for composite %{name} version %{version}, but no components updated.") %
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
          total_count = total_counts(input)
          _("Incremental Update of %{content_view_count} Content View Version(s) " %
            {:content_view_count => total_count[:content_view_count]}) + content_output(total_count)
        end

        def total_counts(input)
          total_count = {}
          if input && input[:version_outputs]
            content_view_count = input[:version_outputs].length
            input[:version_outputs].map do |version_output|
              added_units = version_output.try(:[], :output).try(:[], :added_units)
              if added_units
                total_count[:errata_count] = added_units[:erratum].try(:count)
                total_count[:rpm_count] = added_units[:rpm].try(:count)
                total_count[:puppet_module_count] = added_units[:puppet_module].try(:count)
              end
            end
          end
          total_count[:content_view_count] = content_view_count
          total_count
        end

        def content_output(total_count)
          content = content_output_collection(total_count)
          if content.count >= 1
            message_output = _("with")
            if content.count == 1
              message_output + content[0]
            else
              message_output += content.pop
              while content.count > 0
                if content.count == 1
                  message_output = message_output + _(", and") + content.pop
                else
                  message_output = message_output + "," + content.pop
                end
              end
            end
          else
            message_output = ""
          end
          message_output
        end

        def content_output_collection(total_count)
          content = []
          if total_count[:errata_count] && total_count[:errata_count] > 0
            errata = _(" %{errata_count} Errata" % {:errata_count => total_count[:errata_count]})
            content << errata
          end
          if total_count[:rpm_count] && total_count[:rpm_count] > 0
            rpm = _(" %{package_count} Package(s)" % {:package_count => total_count[:rpm_count]})
            content << rpm
          end
          if total_count[:puppet_module_count] && total_count[:puppet_module_count] > 0
            puppet_module = _(" %{puppet_module_count} Puppet Module(s)" %
                              {:puppet_module_count => total_count[:puppet_module_count]})
            content << puppet_module
          end
          content
        end

        def presenter
          Presenters::IncrementalUpdatesPresenter.new(self)
        end
      end
    end
  end
end
