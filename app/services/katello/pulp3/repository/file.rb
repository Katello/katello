require 'pulp_file_client'

module Katello
  module Pulp3
    class Repository
      class File < ::Katello::Pulp3::Repository
        def copy_content_for_source(source_repository, _options = {})
          copy_units_by_href(source_repository.files.pluck(:pulp_id))
        end

        def distribution_options(path)
          {
            base_path: path,
            publication: repo.publication_href,
            name: "#{generate_backend_object_name}",
          }
        end

        def remote_options
          options = common_remote_options
          #TODO: move to user specifying PULP_MANIFEST
          if root.url.blank?
            options[:url] = nil
          else
            options[:url] = root.url + '/PULP_MANIFEST'
          end
          options.merge!(policy: root.download_policy)
        end

        def partial_repo_path
          "/pulp/isos/#{repo.relative_path}/PULP_MANIFEST"
        end
      end
    end
  end
end
