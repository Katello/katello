module Actions
  module Katello
    module ContentViewVersion
      class IncrementalUpdate < Actions::EntryAction
        attr_accessor :new_content_view_version

        def humanized_name
          _("Incremental Update")
        end

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
          self.new_content_view_version = old_version.content_view.create_new_version(description, old_version.major, new_minor, all_components)
          history = ::Katello::ContentViewHistory.create!(:content_view_version => new_content_view_version, :user => ::User.current.login,
                                                          :status => ::Katello::ContentViewHistory::IN_PROGRESS, :task => self.task)

          copy_action_outputs = []

          sequence do
            concurrence do
              repos_to_copy(old_version, new_components).each do |source_repo|
                copy_action_outputs += copy_repo(source_repo, new_content_view_version, content, dep_solve)
              end

              sequence do
                new_puppet_environment = plan_action(Katello::ContentViewPuppetEnvironment::Clone, old_version,
                                                   :new_version => new_content_view_version).new_puppet_environment
                copy_action_outputs += copy_puppet_content(new_puppet_environment, content[:puppet_module_ids]) unless content[:puppet_module_ids].blank?
              end
            end

            plan_self(:content_view_id => old_version.content_view.id, :environment_ids => environments.map(&:id),
                      :user_id => ::User.current.id, :history_id => history.id, :copy_action_outputs => copy_action_outputs)
            promote(new_content_view_version, environments)
          end
        end

        def repos_to_copy(old_version, components)
          old_version.archived_repos.map do |source_repo|
            components_repo_instance(source_repo, components) || source_repo
          end
        end

        def copy_repo(source_repo, new_version, content, dep_solve)
          copy_output = []
          sequence do
            new_repo = plan_action(Repository::CloneToVersion, source_repo, new_version, true).new_repository
            copy_output = copy_yum_content(new_repo, dep_solve, content[:package_ids], content[:errata_ids])

            plan_action(Katello::Repository::MetadataGenerate, new_repo, nil)
            plan_action(Katello::Repository::IndexContent, id: new_repo.id)
          end
          copy_output
        end

        # for a given repo, find its instance out of a list of content view versions.  Since these versions
        #  are all part of a composite, there should only be one
        def components_repo_instance(repo, component_versions)
          possible_repos = component_versions.map do |cvv|
            cvv.repositories.select do |component_repo|
              component_repo.library_instance_id == repo.library_instance_id
            end
          end
          possible_repos.flatten.first
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
          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!
        end

        # given a composite version, and a list of new components, calculate the list of all components for the new version
        def calculate_components(old_version, new_components)
          old_components = old_version.components.select do |component|
            !old_version.components.map(&:content_view_id).include?(component.content_view_id)
          end
          old_components + new_components
        end

        private

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
          concurrence do
            environments.each do |environment|
              plan_action(Katello::ContentView::Promote, new_version, environment, true)
            end
          end
        end

        def copy_yum_content(new_repo, dep_solve, package_uuids, errata_uuids)
          copy_outputs = []
          if new_repo.content_type == ::Katello::Repository::YUM_TYPE
            unless errata_uuids.blank?
              copy_outputs << plan_copy(Pulp::Repository::CopyErrata, new_repo.library_instance, new_repo,
                                        { :filters => {:association => {'unit_id' => {'$in' => errata_uuids}}}},
                                        :recursive => true, :resolve_dependencies => dep_solve).output
            end

            unless package_uuids.blank?
              copy_outputs << plan_copy(Pulp::Repository::CopyRpm, new_repo.library_instance, new_repo,
                                        { :filters => {:association => {'unit_id' => {'$in' => package_uuids}}}},
                                        :resolve_dependencies => dep_solve).output
            end
          end
          copy_outputs
        end

        def puppet_module_names(uuids)
          ::Katello::PuppetModule.id_search(uuids).map(&:name)
        end

        def remove_puppet_names(repo, names)
          plan_action(Pulp::Repository::RemovePuppetModule, :pulp_id => repo.pulp_id, :clauses => {:unit => {:name => {'$in' => names}}})
        end

        def copy_puppet_content(new_repo, puppet_module_uuids)
          copy_outputs = []
          unless puppet_module_uuids.blank?
            remove_puppet_names(new_repo, puppet_module_names(puppet_module_uuids))
            copy_outputs = puppet_module_uuids.map { |uuid| copy_puppet_module(new_repo, uuid).output }
            plan_action(Pulp::ContentViewPuppetEnvironment::IndexContent, id: new_repo.id)
          end
          copy_outputs
        end

        def copy_puppet_module(new_repo, uuid)
          possible_repos = ::Katello::PuppetModule.find(uuid).repositories.in_organization(new_repo.organization).in_default_view
          plan_action(Pulp::Repository::CopyPuppetModule, :source_pulp_id => possible_repos.first.pulp_id,
                    :target_pulp_id => new_repo.pulp_id, :clauses =>  {'unit_id' => uuid}, :include_result => true)
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
