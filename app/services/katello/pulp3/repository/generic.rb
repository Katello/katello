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
          generic_remote_options = JSON.parse(root.generic_remote_options)
          if generic_remote_options.any?
            common_remote_options.merge(generic_remote_options.select { |_, v| !v.nil? }).symbolize_keys
          else
            common_remote_options
          end
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

        def create_distribution(path)
          distribution_data = api.class.distribution_class(repo.repository_type).new(secure_distribution_options(path))
          api.distributions_api.create(distribution_data)
        end

        def refresh_distributions
          dist = lookup_distributions(base_path: repo.relative_path).first

          # First check if the distribution exists
          if dist
            dist_ref = distribution_reference
            # If we have a DistributionReference, update the distribution
            if dist_ref
              return update_distribution
              # If no DistributionReference, create a DistributionReference and return
            else
              save_distribution_references([dist.pulp_href])
              return []
            end
          end

          # So far, it looks like there is no distribution. Try to create one.
          begin
            create_distribution(relative_path)
          rescue api.client_module::ApiError => e
            # Now it seems there is a distribution. Fetch it and save the reference.
            if e.message.include?("\"base_path\":[\"This field must be unique.\"]") ||
              e.message.include?("\"base_path\":[\"Overlaps with existing distribution\"")
              dist = lookup_distributions(base_path: repo.relative_path).first
              save_distribution_references([dist.pulp_href])
              return []
            else
              raise e
            end
          end
        end

        def sync(options = {})
          repository_sync_url_data = api.class.repository_sync_url_class(repo.repository_type).new(sync_url_params(options))
          [api.repositories_api.sync(repository_reference.repository_href, repository_sync_url_data)]
        end

        def create_publication
          publication_data = api.class.publication_class(repo.repository_type).new(publication_options(repo.version_href))
          api.publications_api.create(publication_data)
        end
      end
    end
  end
end
