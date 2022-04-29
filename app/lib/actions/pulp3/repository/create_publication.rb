module Actions
  module Pulp3
    module Repository
      class CreatePublication < Pulp3::AbstractAsyncTask
        middleware.use Actions::Middleware::ExecuteIfContentsChanged
        def plan(repository, smart_proxy, options)
          sequence do
            action = plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id, :contents_changed => options[:contents_changed],
                               :skip_publication_creation => options[:skip_publication_creation],
                               :deb_simple_publish_only => options[:deb_simple_publish_only])
            plan_action(SavePublication, repository, action.output, :contents_changed => options[:contents_changed])
          end
        end

        def invoke_external_task
          unless input[:skip_publication_creation]
            repository = ::Katello::Repository.find(input[:repository_id])
            output[:response] = repository.backend_service(smart_proxy).with_mirror_adapter.create_publication({
              :deb_simple_publish_only => input[:deb_simple_publish_only]
            })
          end
        end
      end
    end
  end
end
