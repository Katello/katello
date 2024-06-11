module Actions
  module Katello
    module Repository
      class Create < Actions::EntryAction
        # rubocop:disable Metrics/MethodLength
        def plan(repository, args = {})
          clone = args[:clone] || false
          force_repo_create = args[:force_repo_create] || false
          repository.save!
          root = repository.root

          action_subject(repository)

          org = repository.organization
          sequence do
            # Container push repositories will already be in pulp. The version_href is
            # directly updated after a push.
            unless root.is_container_push && repository.in_default_view?
              create_action = plan_action(Pulp3::Orchestration::Repository::Create,
                                          repository, SmartProxy.pulp_primary, force_repo_create)
              return if create_action.error
            end

            # when creating a clone, the following actions are handled by the
            # publish/promote process
            unless clone
              view_env = org.default_content_view.content_view_environment(org.library)
              if repository.product.redhat?
                plan_action(Actions::Candlepin::Environment::AddContentToEnvironment, :view_env_cp_id => view_env.cp_id, :content_id => repository.content_id)
              else
                unless root.content
                  content_create = plan_action(Katello::Product::ContentCreate, root)
                  plan_action(Actions::Candlepin::Environment::AddContentToEnvironment, :view_env_cp_id => view_env.cp_id, :content_id => content_create.input[:content_id])
                end
              end
            end

            # Container push repos do not need metadata generation or ACS (they do not sync)
            unless root.is_container_push && repository.in_default_view?
              concurrence do
                plan_self(:repository_id => repository.id, :clone => clone)
                if !clone && repository.url.present?
                  repository.product.alternate_content_sources.with_type(repository.content_type).each do |acs|
                    acs.smart_proxies.each do |smart_proxy|
                      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id, repository_id: repository.id)
                      plan_action(Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
                    end
                  end
                end
              end
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
