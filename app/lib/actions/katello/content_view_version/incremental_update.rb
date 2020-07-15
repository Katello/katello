module Actions
  module Katello
    module ContentViewVersion
      class IncrementalUpdate < Actions::EntryAction
        attr_accessor :new_content_view_version

        HUMANIZED_TYPES = {
          ::Katello::Erratum::CONTENT_TYPE => "Errata",
          ::Katello::Rpm::CONTENT_TYPE => "Packages",
          ::Katello::Deb::CONTENT_TYPE => "Deb Packages",
          ::Katello::PuppetModule::CONTENT_TYPE => "Puppet Modules"
        }.freeze

        def humanized_name
          _("Incremental Update")
        end

        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/AbcSize
        def plan(old_version, environments, options = {})
          dep_solve = options.fetch(:resolve_dependencies, true)
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
          repos_to_clone = repos_to_copy(old_version, new_components)

          sequence do
            repository_mapping = plan_action(ContentViewVersion::CreateRepos, new_content_view_version, repos_to_clone).repository_mapping

            repos_to_clone.each do |source_repos|
              plan_action(Repository::CloneToVersion,
                          source_repos,
                          new_content_view_version,
                          repository_mapping[source_repos],
                          incremental: true)
            end

            concurrence do
              if SmartProxy.pulp_master.pulp3_support?(repos_to_clone.first.first)
                extended_repo_mapping = pulp3_repo_mapping(repository_mapping, old_version)
                unit_map = pulp3_content_mapping(content)

                unless extended_repo_mapping.empty?
                  copy_action_outputs << plan_action(Pulp3::Repository::MultiCopyUnits, extended_repo_mapping, unit_map,
                                                     dependency_solving: true).output
                end
              else
                repos_to_clone.each do |source_repos|
                  copy_action_outputs += copy_repos(repository_mapping[source_repos],
                                                    new_content_view_version,
                                                    content,
                                                    dep_solve)
                end
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
                      :history_id => history.id, :copy_action_outputs => copy_action_outputs,
                      :old_version => old_version.id)
            promote(new_content_view_version, environments)
          end
        end

        def pulp3_content_mapping(content)
          units = ::Katello::Erratum.with_identifiers(content[:errata_ids]) +
            ::Katello::Rpm.with_identifiers(content[:package_ids])
          unit_map = { :errata => [], :rpms => [] }
          units.each do |unit|
            if unit.class.name == "Katello::Erratum"
              unit_map[:errata] << unit.id
            elsif unit.class.name == "Katello::Rpm"
              unit_map[:rpms] << unit.id
            end
          end
          unit_map
        end

        def pulp3_repo_mapping(repo_mapping, old_version)
          pulp3_repo_mapping = {}
          repo_mapping.each do |source_repo, dest_repo|
            # FIXME: Other source repos are being thrown away here
            old_version_repo = old_version.repositories.archived.find_by(root_id: dest_repo.root_id)

            next if old_version_repo.version_href == old_version_repo.library_instance.version_href

            source_repo = source_repo.first.library_instance? ? source_repo : [source_repo.first.library_instance]
            pulp3_repo_mapping[source_repo.first.id] = { dest_repo: dest_repo.id,
                                                         base_version: old_version_repo.version_href.split("/")[-1].to_i }
          end
          pulp3_repo_mapping
        end

        def repos_to_copy(old_version, new_components)
          old_version.archived_repos.map do |source_repo|
            components_repo_instances(source_repo, new_components)
          end
        end

        def copy_repos(new_repo, new_version, content, dep_solve)
          copy_output = []
          sequence do
            solve_dependencies = new_version.content_view.solve_dependencies || dep_solve
            copy_output += copy_deb_content(new_repo, solve_dependencies, content[:deb_ids])
            copy_output += copy_yum_content(new_repo, solve_dependencies,
                                            content[:package_ids],
                                            content[:errata_ids])

            plan_action(Katello::Repository::MetadataGenerate, new_repo)
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
                      ::Katello::ModuleStream::CONTENT_TYPE => [],
                      ::Katello::Deb::CONTENT_TYPE => [],
                      ::Katello::PuppetModule::CONTENT_TYPE => []
                    }

          base_repos = ::Katello::ContentViewVersion.find(input[:old_version]).repositories
          new_repos = ::Katello::ContentViewVersion.find(input[:new_content_view_version_id]).repositories

          if input[:copy_action_outputs].present?
            if input[:copy_action_outputs].last[:pulp_tasks].last[:pulp_href].include?("/pulp/api/v3/")
              new_repos.each do |new_repo|
                matched_old_repo = base_repos.where(root_id: new_repo.root_id).first

                new_errata = new_repo.errata - matched_old_repo.errata
                new_module_streams = new_repo.module_streams - matched_old_repo.module_streams
                new_rpms = new_repo.rpms - matched_old_repo.rpms

                new_errata.each do |erratum|
                  content[::Katello::Erratum::CONTENT_TYPE] << erratum.errata_id
                end
                new_module_streams.each do |module_stream|
                  content[::Katello::ModuleStream::CONTENT_TYPE] <<
                    "#{module_stream.name}:#{module_stream.stream}:#{module_stream.version}"
                end
                new_rpms.each do |rpm|
                  content[::Katello::Rpm::CONTENT_TYPE] << rpm.nvra
                end
              end
            else
              input[:copy_action_outputs].each do |copy_output|
                copy_output[:pulp_tasks].each do |pulp_task|
                  pulp_task[:result][:units_successful].each do |unit|
                    type = unit['type_id']
                    unit = unit['unit_key']
                    case type
                    when ::Katello::Erratum::CONTENT_TYPE
                      content[::Katello::Erratum::CONTENT_TYPE] << unit['id']
                    when ::Katello::ModuleStream::CONTENT_TYPE
                      content[::Katello::ModuleStream::CONTENT_TYPE] << "#{unit['name']}:#{unit['stream']}:#{unit['version']}"
                    when ::Katello::Rpm::CONTENT_TYPE
                      content[::Katello::Rpm::CONTENT_TYPE] << ::Katello::Util::Package.build_nvra(unit)
                    when ::Katello::Deb::CONTENT_TYPE
                      content[::Katello::Deb::CONTENT_TYPE] << "#{unit['name']}_#{unit['version']}_#{unit['architecture']}"
                    when ::Katello::PuppetModule::CONTENT_TYPE
                      content[::Katello::PuppetModule::CONTENT_TYPE] << "#{unit['author']}-#{unit['name']}-#{unit['version']}"
                    end
                  end
                end
              end
            end
          end
          output[:added_units] = content
        end

        def finalize
          version = ::Katello::ContentViewVersion.find(input[:new_content_view_version_id])
          version.update_content_counts!
          generate_description(version, output[:added_units]) if version.description.blank?

          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!

          unless SmartProxy.pulp_master.pulp3_support?(version.repositories.first)
            version.repositories.each do |repo|
              SmartProxy.pulp_master.pulp_api.extensions.send(:module_default).
                copy(repo.library_instance.pulp_id,
                repo.pulp_id)
            end
          end
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

        def copy_deb_content(new_repo, dep_solve, deb_ids)
          copy_outputs = []
          if new_repo.content_type == ::Katello::Repository::DEB_TYPE
            unless deb_ids.blank?
              copy_outputs << plan_action(Pulp::Repository::CopyUnits, new_repo.library_instance, new_repo,
                                          ::Katello::Deb.with_identifiers(deb_ids),
                                          incremental_update: dep_solve).output
            end
          end
          copy_outputs
        end

        def copy_yum_content(new_repo, dep_solve, package_ids, errata_ids)
          copy_outputs = []
          if new_repo.content_type == ::Katello::Repository::YUM_TYPE
            unless errata_ids.blank?
              copy_outputs << plan_action(Pulp::Repository::CopyUnits, new_repo.library_instance, new_repo,
                                          ::Katello::Erratum.with_identifiers(errata_ids),
                                          incremental_update: dep_solve).output
            end

            unless package_ids.blank?
              copy_outputs << plan_action(Pulp::Repository::CopyUnits, new_repo.library_instance, new_repo,
                                          ::Katello::Rpm.with_identifiers(package_ids),
                                          incremental_update: dep_solve).output
            end
          end
          copy_outputs
        end

        def remove_puppet_modules(repo, puppet_module_ids)
          plan_action(Pulp::Repository::RemoveUnits, :content_view_puppet_environment_id => repo.id, :contents => puppet_module_ids, :content_unit_type => ::Katello::PuppetModule::CONTENT_TYPE)
        end

        def copy_puppet_content(new_repo, puppet_module_ids)
          copy_outputs = []
          unless puppet_module_ids.blank?
            remove_puppet_modules(new_repo, puppet_module_ids)
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
          plan_action(Pulp::ContentViewPuppetEnvironment::CopyContents, new_repo, source_repository_id: possible_repos.first.id, puppet_modules: [puppet_module])
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
