module Katello
  module Pulp3
    class Repository
      class Generic < ::Katello::Pulp3::Repository
        def copy_content_for_source(source_repository, _options = {})
          copy_units_by_href(source_repository.generic_content_units&.pluck(:pulp_id))
        end

        def distribution_options(path)
          options = {
            base_path: path,
            name: "#{generate_backend_object_name}",
          }

          if ::Katello::RepositoryTypeManager.find(repo.content_type).pulp3_skip_publication
            options.merge!(repository_version: repo.version_href)
          else
            options.merge!(publication: repo.publication_href)
          end

          options
        end

        def remote_options
          generic_remote_options = JSON.parse(root.generic_remote_options)
          if generic_remote_options.any?
            common_remote_options.merge(generic_remote_options).symbolize_keys
          else
            common_remote_options
          end
        end

        def partial_repo_path
          "/pulp/content/#{repo.relative_path}/".sub('//', '/')
        end
      end
    end
  end
end
