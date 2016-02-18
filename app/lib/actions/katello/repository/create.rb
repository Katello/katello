module Actions
  module Katello
    module Repository
      class Create < Actions::EntryAction
        def plan(repository, clone = false, plan_create = false, ostree_branches = [])
          repository.save!
          ostree_branches.each do |branch_name|
            repository.ostree_branches.create!(:name => branch_name)
          end if ostree_branches
          action_subject(repository)

          org = repository.organization
          path = repository.relative_path unless repository.puppet?

          create_action = plan_create ? Actions::Pulp::Repository::CreateInPlan : Actions::Pulp::Repository::Create
          sequence do
            create_action = plan_action(create_action,
                                        content_type: repository.content_type,
                                        pulp_id: repository.pulp_id,
                                        name: repository.name,
                                        docker_upstream_name: repository.docker_upstream_name,
                                        feed: repository.url,
                                        ssl_ca_cert: repository.feed_ca,
                                        ssl_client_cert: repository.feed_cert,
                                        ssl_client_key: repository.feed_key,
                                        unprotected: repository.unprotected,
                                        checksum_type: repository.checksum_type,
                                        path: path,
                                        download_policy: repository.download_policy,
                                        with_importer: true,
                                        ostree_branches: repository.ostree_branch_names)

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
              plan_action(::Actions::Pulp::Repos::Update, repository.product) if repository.product.sync_plan
              plan_self(:repository_id => repository.id) unless repository.puppet?
            end
          end
        end

        def run
          ::User.current = ::User.anonymous_api_admin
          repository = ::Katello::Repository.find(input[:repository_id])
          ForemanTasks.async_task(Katello::Repository::MetadataGenerate, repository)
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
