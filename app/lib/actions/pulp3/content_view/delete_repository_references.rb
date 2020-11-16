module Actions
  module Pulp3
    module ContentView
      class DeleteRepositoryReferences < Pulp3::AbstractAsyncTask
        def plan(content_view, smart_proxy)
          if content_view.repository_references.any?
            plan_self(:content_view_id => content_view.id, :smart_proxy_id => smart_proxy.id)
          end
        end

        def invoke_external_task
          tasks = []
          content_view = ::Katello::ContentView.find(input[:content_view_id])
          content_view.repository_references.each do |repository_reference|
            repo = repository_reference.root_repository.library_instance
            #force pulp3 in case we've done migrations, but haven't switched over yet
            tasks << repo.backend_service(smart_proxy, true).delete_repository(repository_reference)
          end
          content_view.repository_references.destroy_all

          output[:pulp_tasks] = tasks
        end
      end
    end
  end
end
