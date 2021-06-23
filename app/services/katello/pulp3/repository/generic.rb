module Katello
  module Pulp3
    class Repository
      class Generic < ::Katello::Pulp3::Repository
        def copy_content_for_source(source_repository, _options = {})
          copy_units_by_href(source_repository.files.pluck(:pulp_id))
        end

        def distribution_options(path)
          {
            base_path: path,
            publication: repo.publication_href,
            name: "#{generate_backend_object_name}"
          }
        end

        def remote_options
          common_remote_options
        end

        def partial_repo_path
          repo.repository_type.partial_repo_path
        end

        def api
          @api ||= repo.repository_type.pulp3_api(smart_proxy)
        end

        def self.api(smart_proxy, repo)
          api_class = RepositoryTypeManager.find_by(:pulp3_service_class, self).pulp3_api_class
          api_class ? api_class.new(smart_proxy, repo) : Katello::Pulp3::Api::Core.new(smart_proxy)
        end
      end
    end
  end
end
