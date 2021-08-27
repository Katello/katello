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
      end
    end
  end
end
