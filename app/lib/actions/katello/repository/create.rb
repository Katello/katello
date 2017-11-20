module Actions
  module Katello
    module Repository
      class Create < Actions::EntryAction
        # rubocop:disable MethodLength
        def plan(repository, clone = false, plan_create = false)
          repository.save!
          action_subject(repository)

          org = repository.organization
          path = repository.relative_path unless repository.puppet?

          create_action = plan_create ? Actions::Pulp::Repository::CreateInPlan : Actions::Pulp::Repository::Create
          sequence do
            certs = repository.importer_connection_options
            create_action = plan_action(create_action,
                                        content_type: repository.content_type,
                                        pulp_id: repository.pulp_id,
                                        name: repository.name,
                                        docker_upstream_name: repository.docker_upstream_name,
                                        feed: repository.url,
                                        ssl_ca_cert: certs[:ssl_ca_cert],
                                        ssl_client_cert: certs[:ssl_client_cert],
                                        ssl_client_key: certs[:ssl_client_key],
                                        unprotected: repository.unprotected,
                                        checksum_type: repository.checksum_type,
                                        path: path,
                                        download_policy: repository.download_policy,
                                        ostree_upstream_sync_depth: repository.compute_ostree_upstream_sync_depth,
                                        ostree_publish_depth: repository.compute_ostree_upstream_sync_depth,
                                        with_importer: true,
                                        mirror_on_sync: repository.mirror_on_sync?,
                                        ssl_validation: certs[:ssl_validation],
                                        upstream_username: repository.upstream_username,
                                        upstream_password: repository.upstream_password,
                                        repo_registry_id: repository.container_repository_name,
                                        proxy_host: repository.proxy_host_value)

            return if create_action.error

            # when creating a clone, the following actions are handled by the
            # publish/promote process
            unless clone
              if repository.product.redhat?
                plan_action(ContentView::UpdateEnvironment, org.default_content_view,
                            org.library, repository.content_id)
              else
                content_create = plan_action(Katello::Product::ContentCreate, repository)
                plan_action(ContentView::UpdateEnvironment, org.default_content_view,
                            org.library, content_create.input[:content_id])
              end
            end

            concurrence do
              if !clone && repository.product.sync_plan
                plan_action(::Actions::Pulp::Repos::Update, repository.product)
              end
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
