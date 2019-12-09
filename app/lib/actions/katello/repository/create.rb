module Actions
  module Katello
    module Repository
      class Create < Actions::EntryAction
        include Actions::Katello::PulpSelector

        def plan(repository, clone = false, plan_create = false)
          repository.save!
          root = repository.root

          action_subject(repository)

          if repository.download_policy == ::Runcible::Models::YumImporter::DOWNLOAD_BACKGROUND
            ::Foreman::Deprecation.api_deprecation_warning("Background download_policy will be removed in Katello 3.16.  Any background repositories will be converted to Immediate")
          end

          if root['content_type'] == 'puppet' || root['content_type'] == 'ostree'
            ::Foreman::Deprecation.api_deprecation_warning("Repository types of 'Puppet' and 'OSTree' will no longer be supported in Katello 3.16.")
          end

          org = repository.organization
          pulp2_create_action = plan_create ? Actions::Pulp::Repository::CreateInPlan : Actions::Pulp::Repository::Create
          sequence do
            create_action = plan_pulp_action([pulp2_create_action, Pulp3::Orchestration::Repository::Create],
                                        repository, SmartProxy.pulp_master)

            return if create_action.error

            # when creating a clone, the following actions are handled by the
            # publish/promote process
            unless clone
              view_env = org.default_content_view.content_view_environment(org.library)
              if repository.product.redhat?
                plan_action(Actions::Candlepin::Environment::AddContentToEnvironment, :view_env_cp_id => view_env.cp_id, :content_id => repository.content_id)
              else
                content_create = plan_action(Katello::Product::ContentCreate, root)
                plan_action(Actions::Candlepin::Environment::AddContentToEnvironment, :view_env_cp_id => view_env.cp_id, :content_id => content_create.input[:content_id])
              end
            end

            concurrence do
              plan_self(:repository_id => repository.id, :clone => clone)
            end
          end
        end

        def run
          ::User.current = ::User.anonymous_api_admin
          unless input[:clone]
            repository = ::Katello::Repository.find(input[:repository_id])
            ForemanTasks.async_task(Katello::Repository::MetadataGenerate, repository)
          end
        ensure
          ::User.current = nil
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
