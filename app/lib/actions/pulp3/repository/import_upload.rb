# This action takes a content unit and a repository
# Creates a content unit based on content type and then creates a new repository version with the added content.
module Actions
  module Pulp3
    module Repository
      class ImportUpload < Pulp3::AbstractAsyncTask
        def plan(content_unit, repository, smart_proxy)
          plan_self(:content_unit => content_unit,
                    :repository_id => repository.id,
                    :smart_proxy_id => smart_proxy.id)
        end

        def invoke_external_task
          content_unit = input[:content_unit]
          content_unit_href = content_unit.is_a?(String) ? content_unit : content_unit.last[:created_resources].first
          repo = ::Katello::Repository.find(input[:repository_id])
          repo_backend_service = repo.backend_service(smart_proxy)
          output[:content_unit_href] = content_unit_href
          output[:pulp_tasks] = [repo_backend_service.add_content(content_unit_href)]
        end
      end
    end
  end
end
