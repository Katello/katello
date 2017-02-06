module Actions
  module Katello
    module ContentViewVersion
      class IncrementalUpdate < Actions::EntryAction
        attr_accessor :new_content_view_version

        HUMANIZED_TYPES = {
          ::Katello::Erratum::CONTENT_TYPE => "Errata",
          ::Katello::Rpm::CONTENT_TYPE => "Packages",
          ::Katello::PuppetModule::CONTENT_TYPE => "Puppet Modules"
        }.freeze

        def humanized_name
          _("Incremental Update")
        end

        # rubocop:disable Metrics/MethodLength
        def plan(old_version, environments, options = {})
          dep_solve = options.fetch(:resolve_dependencies, false)
          description = options.fetch(:description, '')
          content = options.fetch(:content, {})
          new_components = options.fetch(:new_components, [])

          is_composite = old_version.content_view.composite?
          all_components = is_composite ? calculate_components(old_version, new_components) : []

          action_subject(old_version.content_view)
          validate_environments(environments, old_version)

          new_minor = old_version.content_view.versions.where(:major => old_version.major).maximum(:minor) + 1
          self.new_content_view_version = old_version.content_view.create_new_version(old_version.major, new_minor, all_components)
          history = ::Katello::ContentViewHistory.create!(:content_view_version => new_content_view_version, :user => ::User.current.login,
                                                          :action => ::Katello::ContentViewHistory.actions[:publish],
                                                          :status => ::Katello::ContentViewHistory::IN_PROGRESS, :task => self.task,
                                                          :notes => description)

          copy_action_outputs = []

          sequence do
            concurrence do
              repos_to_copy(old_version, new_components).each do |source_repos|
                copy_action_outputs += copy_repos(source_repos, new_content_view_version, content, dep_solve)
              end

              sequence do
                new_puppet_environment = plan_action(Katello::ContentViewPuppetEnvironment::Clone, old_version,
                                                   :new_version => new_content_view_version).new_puppet_environment
                copy_action_outputs += copy_puppet_content(new_puppet_environment, content[:puppet_module_ids]) unless content[:puppet_module_ids].blank?
              end
            end

            plan_self(:content_view_id => old_version.content_view.id,
                      :new_content_view_version_id => self.new_content_view_version.id,
                      :environment_ids => environments.map(&:id), :user_id => ::User.current.id,
                      :history_id => history.id, :copy_action_outputs => copy_action_outputs)
            promote(new_content_view_version, environments)
          end
        end

        def repos_to_copy(old_version, new_components)
          old_version.archived_repos.map do |source_repo|
            components_repo_instances(source_repo, new_components)
          end
        end

        def copy_repos(source_repos, new_version, content, dep_solve)
          copy_output = []
          sequence do
            new_repo = plan_action(Repository::CloneToVersion, source_repos, new_version, true).new_repository
            copy_output = copy_yum_content(new_repo, dep_solve, content[:package_ids], content[:errata_ids])

            plan_action(Katello::Repository::MetadataGenerate, new_repo, nil)
            plan_action(Katello::Repository::IndexContent, id: new_repo.id)
          end
          copy_output
        end

        # For a given repo, find it's instances in both the new and old component versions.
        # This is necessary, since a composite content view may have components containing
        # the same repository within multiple component views and all of the source repos
        # will be needed to publish the new repo.
        def components_repo_instances(old_version_repo, new_component_versions)
          # Attempt to locate the repo instance in the new component versions
          new_repos = nil
          new_component_versions.map do |cvv|
            cvv.repositories.each do |component_repo|
              if component_repo.library_instance_id == old_version_repo.library_instance_id
                new_repos ||= []
                new_repos << component_repo
                break # each CVV can only have 1 repo with this instance id, so go to next CVV
              end
            end
          end

          # If we found it, we need to also locate the repo instance in the old component
          # versions, but omit the one changed by the new component version.
          if new_repos
            old_repos = nil
            old_version_repo.content_view_version.components.each do |component|
              component.archived_repos.each do |component_repo|
                # if the archived repo is not the same source as one of the new repos, include it
                new_repos.each do |new_repo|
                  if (new_repo.library_instance_id == component_repo.library_instance_id) &&
                      (new_repo.content_view.id != component_repo.content_view.id)
                    old_repos ||= []
                    old_repos << component_repo
                  end
                end
              end
            end
            new_repos.concat(old_repos) unless old_repos.blank?
            new_repos
          else
            [old_version_repo]
          end
        end

        def run
          content = { ::Katello::Erratum::CONTENT_TYPE => [],
                      ::Katello::Rpm::CONTENT_TYPE => [],
                      ::Katello::PuppetModule::CONTENT_TYPE => []}

          input[:copy_action_outputs].each do |copy_output|
            copy_output[:pulp_tasks].each do |pulp_task|
              pulp_task[:result][:units_successful].each do |unit|
                type = unit['type_id']
                unit = unit['unit_key']
                case type
                when ::Katello::Erratum::CONTENT_TYPE
                  content[::Katello::Erratum::CONTENT_TYPE] << unit['id']
                when ::Katello::Rpm::CONTENT_TYPE
                  content[::Katello::Rpm::CONTENT_TYPE] << ::Katello::Util::Package.build_nvra(unit)
                when ::Katello::PuppetModule::CONTENT_TYPE
                  content[::Katello::PuppetModule::CONTENT_TYPE] << "#{unit['author']}-#{unit['name']}-#{unit['version']}"
                end
              end
            end
          end
          output[:added_units] = content
        end

        def finalize
          version = ::Katello::ContentViewVersion.find(input[:new_content_view_version_id])
          generate_description(version, output[:added_units]) if version.description.blank?

          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!
        end

        # given a composite version, and a list of new components, calculate the list of all components for the new version
        def calculate_components(old_version, new_components)
          old_components = old_version.components.select do |component|
            !new_components.map(&:content_view_id).include?(component.content_view_id)
          end
          old_components + new_components
        end

        private

        def generate_description(version, content)
          humanized_lines = []
          [::Katello::Erratum, ::Katello::Rpm, ::Katello::PuppetModule].each do |content_type|
            unless content[content_type::CONTENT_TYPE].blank?
              humanized_lines << "#{HUMANIZED_TYPES[content_type::CONTENT_TYPE]}:"
              humanized_lines += content[content_type::CONTENT_TYPE].sort.map { |unit| "    #{unit}" }
            end
            humanized_lines << ''
          end

          version_history = version.history.publish.first
          if version_history.notes
            version_history.notes += "\n"
          else
            version_history.notes = ''
          end

          version_history.notes += humanized_lines.join("\n")
          version_history.save!
          version.save!
        end

        def validate_environments(to_environments, old_version)
          unless (to_environments - old_version.environments).empty?
            fail _("Content View Version %{id} not in all specified environments %{envs}") %
                     {:id => old_version.id, :envs => (to_environments - old_version.environments).map(&:name).join(',')}
          end
        end

        def validate_content(old_version, content, components)
          if old_version.content_view.composite?
            fail(_("Cannot specify content for composite views")) unless content.empty?
            validate_components(old_version, components)
          else
            fail(_("Cannot specify components for non-composite views")) unless components.empty?
          end
        end

        def validate_components(old_version, components)
          old_component_content_view_ids = old_version.components.map(&:content_view_id)
          components.each do |cvv|
            unless old_component_content_view_ids.include?(cvv.content_view_id)
              fail _("No Version of Content View %{component} already exists as a component of the composite Content View %{composite} version %{version}") %
                {:component => self.content_vew.name, :composite => old_version.content_view.name, :version => version.version}
            end
          end
        end

        def promote(new_version, environments)
          plan_action(Katello::ContentView::Promote, new_version, environments, true)
        end

        def copy_yum_content(new_repo, dep_solve, package_ids, errata_ids)
          copy_outputs = []
          if new_repo.content_type == ::Katello::Repository::YUM_TYPE
            unless errata_ids.blank?
              errata_uuids = ::Katello::Erratum.with_identifiers(errata_ids).pluck(:uuid)
              copy_outputs << plan_copy(Pulp::Repository::CopyErrata, new_repo.library_instance, new_repo,
                                        { :filters => {:association => {'unit_id' => {'$in' => errata_uuids}}}},
                                        :recursive => true, :resolve_dependencies => dep_solve).output
            end

            unless package_ids.blank?
              package_uuids = ::Katello::Rpm.with_identifiers(package_ids).pluck(:uuid)
              copy_outputs << plan_copy(Pulp::Repository::CopyRpm, new_repo.library_instance, new_repo,
                                        { :filters => {:association => {'unit_id' => {'$in' => package_uuids}}}},
                                        :resolve_dependencies => dep_solve).output
            end
          end
          copy_outputs
        end

        def puppet_module_names(ids)
          find_puppet_modules(ids).pluck(:name).uniq
        end

        def remove_puppet_names(repo, names)
          plan_action(Pulp::Repository::RemovePuppetModule, :pulp_id => repo.pulp_id, :clauses => {:unit => {:name => {'$in' => names}}})
        end

        def copy_puppet_content(new_repo, puppet_module_ids)
          copy_outputs = []
          unless puppet_module_ids.blank?
            remove_puppet_names(new_repo, puppet_module_names(puppet_module_ids))
            copy_outputs = puppet_module_ids.map { |module_id| copy_puppet_module(new_repo, module_id).output }
            plan_action(Pulp::ContentViewPuppetEnvironment::IndexContent, id: new_repo.id)
          end
          copy_outputs
        end

        def find_puppet_modules(ids)
          ::Katello::PuppetModule.with_identifiers(ids)
        end

        def copy_puppet_module(new_repo, module_id)
          puppet_module = find_puppet_modules([module_id]).first
          possible_repos = puppet_module.repositories.in_organization(new_repo.organization).in_default_view
          plan_action(Pulp::Repository::CopyPuppetModule, :source_pulp_id => possible_repos.first.pulp_id,
                    :target_pulp_id => new_repo.pulp_id, :clauses => {'unit_id' => puppet_module.uuid}, :include_result => true)
        end

        def plan_copy(action_class, source_repo, target_repo, clauses = nil, override_config = nil)
          plan_action(action_class,
                      :source_pulp_id => source_repo.pulp_id,
                      :target_pulp_id => target_repo.pulp_id,
                      :full_clauses => clauses,
                      :override_config => override_config,
                      :include_result => true)
        end
      end
    end
  end
end
