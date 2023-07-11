# This action takes a content unit and a repository
# Creates a content unit based on content type and then creates a new repository version with the added content.
module Actions
  module Pulp3
    module Repository
      class ImportUpload < Pulp3::AbstractAsyncTask
        def plan(save_artifact_output, repository, smart_proxy, options = {})
          plan_self(:save_artifact_output => save_artifact_output,
                    :repository_id => repository.id,
                    :smart_proxy_id => smart_proxy.id,
                    :options => options)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          repo_backend_service = repo.backend_service(smart_proxy)

          if input[:save_artifact_output][:pulp_tasks]&.any?
            if repo.deb?
              content_unit_href = input[:save_artifact_output][:pulp_tasks].last[:created_resources].find { |href| href.include?("/deb/packages") }
            else
              content_unit_href = input[:save_artifact_output][:pulp_tasks].last[:created_resources].first
            end
          else
            content_unit_href = input[:save_artifact_output][:content_unit_href]
          end

          output[:content_unit_href] = content_unit_href
          if repo.deb?
            output[:pulp_tasks] = input[:save_artifact_output][:pulp_tasks]
          else
            output[:pulp_tasks] = [repo_backend_service.add_content(content_unit_href)]
          end
        end
      end
    end
  end
end
