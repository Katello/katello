# This action takes a content unit and a repository
# Creates a content unit based on content type and then creates a new repository version with the added content.
module Actions
  module Pulp3
    module Repository
      class ImportUpload < Pulp3::AbstractAsyncTask
        def plan(content_unit, repository, smart_proxy, options = {})
          plan_self(:content_unit => content_unit,
                    :repository_id => repository.id,
                    :smart_proxy_id => smart_proxy.id,
                    :options => options)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          repo_backend_service = repo.backend_service(smart_proxy)

          Rails.logger.debug("Pulp3::Repository::ImportUpload input  #{input}")

          if input[:options][:unit_type_id] == 'ostree_ref'
            artifact_href = input[:options][:artifact_href]
            repo_name = input[:options][:repository_name]
            ref = input[:options][:ref]
            parent_commit = input[:options][:parent_commit]
            output[:pulp_tasks] = [repo_backend_service.import_content(artifact_href, repo_name, ref, parent_commit)]
          else
            content_unit = input[:content_unit]
            content_unit_href = content_unit.is_a?(String) ? content_unit : content_unit.last[:created_resources].first
            output[:content_unit_href] = content_unit_href
            output[:pulp_tasks] = [repo_backend_service.add_content(content_unit_href)]
          end
        end
      end
    end
  end
end
