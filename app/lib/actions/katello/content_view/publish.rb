module Actions
  module Katello
    module ContentView
      class Publish < Actions::EntryAction
        extend ApipieDSL::Class
        include ::Katello::ContentViewHelper
        include ::Actions::ObservableAction
        attr_accessor :version
        execution_plan_hooks.use :trigger_capsule_sync, :on => :success
        execution_plan_hooks.use :notify_on_failure, :on => [:failure, :paused]

        # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity
        def plan(content_view, description = "", options = {importing: false, syncable: false}) # rubocop:disable Metrics/PerceivedComplexity
          action_subject(content_view)

          content_view.check_ready_to_publish!(**options.slice(:importing, :syncable))
          unless options[:importing] || options[:syncable]
            ::Katello::Util::CandlepinRepositoryChecker.check_repositories_for_publish!(content_view)
          end

          if options[:repos_units].present?
            valid_labels_from_cv = content_view.repositories.map(&:label)
            labels_from_repos_units = options[:repos_units].map { |repo| repo[:label] }

            labels_from_repos_units.each do |label|
              fail _("Repository label '%s' is not associated with content view.") % label unless valid_labels_from_cv.include? label
            end

            valid_labels_from_cv.each do |label|
              fail _("Content view has repository label '%s' which is not specified in repos_units parameter.") % label unless labels_from_repos_units.include? label
            end
          end

          # Add non-override components back in
          options[:override_components] = include_other_components(options[:override_components], content_view)

          version = version_for_publish(content_view, options)
          self.version = version
          library = content_view.organization.library
          history = ::Katello::ContentViewHistory.create!(:content_view_version => version,
                                                          :user => ::User.current.login,
                                                          :status => ::Katello::ContentViewHistory::IN_PROGRESS,
                                                          :action => ::Katello::ContentViewHistory.actions[:publish],
                                                          :task => self.task,
                                                          :notes => description,
                                                          :triggered_by => options[:triggered_by]
                                                         )
          source_repositories = []
          content_view.publish_repositories(options[:override_components]) do |repositories|
            source_repositories += [repositories]
          end

          sequence do
            plan_action(ContentView::AddToEnvironment, version, library) unless options[:skip_promotion]
            repository_mapping = plan_action(ContentViewVersion::CreateRepos, version, source_repositories).repository_mapping
            # Split Pulp 3 Yum repos out of the repository_mapping.  Only Pulp 3 RPM plugin has multi repo copy support.
            separated_repo_map = separated_repo_mapping(repository_mapping, content_view.solve_dependencies)

            if options[:importing]
              handle_import(version, **options.slice(:path, :metadata))
            elsif separated_repo_map[:pulp3_yum_multicopy].keys.flatten.present?
              plan_action(Repository::MultiCloneToVersion, separated_repo_map[:pulp3_yum_multicopy], version)
            end

            concurrence do
              source_repositories.each do |repositories|
                sequence do
                  if !options[:importing] && repositories.present? && separated_repo_map[:other].keys.include?(repositories)
                    plan_action(Repository::CloneToVersion, repositories, version, repository_mapping[repositories],
                                :repos_units => options[:repos_units])
                  end
                  plan_action(Repository::CloneToEnvironment, repository_mapping[repositories], library) unless options[:skip_promotion]
                end
              end

              repos_to_delete(content_view).each do |repo|
                plan_action(Repository::Destroy, repo, :skip_environment_update => true)
              end
            end

            plan_action(Candlepin::Environment::SetContent, content_view, library, content_view.content_view_environment(library)) unless options[:skip_promotion]
            plan_action(Katello::Foreman::ContentUpdate, library, content_view) unless options[:skip_promotion]
            plan_action(ContentView::ErrataMail, content_view, library) unless options[:skip_promotion]
            plan_action(ContentView::Promote, version, find_environments(options[:environment_ids]), options[:is_force_promote]) if options[:environment_ids]&.any?
            plan_self(history_id: history.id, content_view_id: content_view.id,
                      auto_publish_composite_ids: auto_publish_composite_ids(content_view),
                      content_view_version_name: version.name,
                      content_view_version_id: version.id,
                      environment_id: library.id, user_id: ::User.current.id, skip_promotion: options[:skip_promotion])
          end
        end

        def humanized_name
          _("Publish")
        end

        def run
          version = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          version.auto_publish_composites!

          output[:content_view_id] = input[:content_view_id]
          output[:content_view_version_id] = input[:content_view_version_id]
          output[:skip_promotion] = input[:skip_promotion]
          output[:history_id] = input[:history_id]
        end

        def rescue_strategy_for_self
          Dynflow::Action::Rescue::Skip
        end

        def finalize
          version = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          version.update_content_counts!
          version.add_applied_filters!
          # update errata applicability counts for all hosts in the CV & Library
          unless input[:skip_promotion]
            environment = ::Katello::KTEnvironment.find(input[:environment_id])
            ::Katello::ContentView.find(input[:content_view_id]).update_host_statuses(environment)
          end

          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!
        end

        def trigger_capsule_sync(_execution_plan)
          environment = ::Katello::KTEnvironment.find(input[:environment_id])
          view = ::Katello::ContentView.find(input[:content_view_id])
          if SmartProxy.sync_needed?(environment) && !input[:skip_promotion]
            ForemanTasks.async_task(ContentView::CapsuleSync,
                                    view,
                                    environment)
          end
        end

        def notify_on_failure(_plan)
          notification = MailNotification[:content_view_publish_failure]
          view = ::Katello::ContentView.find(input.fetch(:content_view, {})[:id])
          notification.users.where(disabled: [nil, false], mail_enabled: true).each do |user|
            notification.deliver(user: user, content_view: view, task: task)
          end
        end

        def content_view_version_id
          input['content_view_version_id']
        end

        def content_view_version_name
          input['content_view_version_name']
        end

        def history_id
          input['history_id']
        end

        private

        def include_other_components(override_components, content_view)
          if override_components.present?
            content_view.components.each do |component|
              component_has_override = override_components.detect do |override_component|
                component.content_view_id == override_component.content_view_id
              end
              unless component_has_override
                override_components << component
              end
            end
            override_components
          end
        end

        def repos_to_delete(content_view)
          if content_view.composite?
            library_instances = content_view.repositories_to_publish.map(&:library_instance_id)
          else
            library_instances = content_view.repositories_to_publish.map(&:id)
          end
          content_view.repos(content_view.organization.library).find_all do |repo|
            !library_instances.include?(repo.library_instance_id)
          end
        end

        def auto_publish_composite_ids(content_view)
          content_view.auto_publish_components.pluck(:composite_content_view_id)
        end

        def version_for_publish(content_view, options)
          if options[:minor] && options[:major]
            if options[:override_components]
              content_view.create_new_version(options[:major], options[:minor], options[:override_components])
            else
              content_view.create_new_version(options[:major], options[:minor])
            end
          else
            content_view.create_new_version
          end
        end

        def find_environments(environment_ids)
          return nil unless environment_ids&.any?
          ::Katello::KTEnvironment.where(:id => environment_ids)
        end

        def handle_import(version, path:, metadata:)
          sequence do
            plan_action(::Actions::Pulp3::Orchestration::ContentViewVersion::Import, version, path: path, metadata: metadata)
            concurrence do
              version.importable_repositories.pluck(:id).each do |id|
                # need to force full_indexing for these version repositories
                # on import. This will then help us correctly copy version units to the library
                plan_action(Katello::Repository::IndexContent, id: id, full_index: true)
              end
            end
            concurrence do
              version.importable_repositories.each do |repo|
                plan_action(::Actions::Katello::Repository::MetadataGenerate, repo)
              end
            end
            plan_action(::Actions::Pulp3::Orchestration::ContentViewVersion::CopyVersionUnitsToLibrary, version)
          end
        end

        apipie :class, "A class representing #{self} object" do
          desc 'This object is available as **@object** variable in
                webhook templates when a corresponding event occures.
                The following properties can be used to retrieve the needed information.'
          name "#{class_scope}"
          refs "#{class_scope}"
          sections only: %w[all webhooks]
          property :task, object_of: 'Task', desc: 'Returns the task to which this action belongs'
          property :content_view_version_id, Integer, desc: 'Returns published content view version id'
          property :content_view_version_name, String, desc: 'Returns published content view version name'
        end
        include Actions::Katello::JailConcern::Organization
        include Actions::Katello::JailConcern::ContentView
        class Jail < ::Actions::ObservableAction::Jail
          allow :organization_id, :organization_name, :organization_label,
                :content_view_id, :content_view_name, :content_view_label,
                :content_view_version_id, :content_view_version_name
        end
      end
    end
  end
end
