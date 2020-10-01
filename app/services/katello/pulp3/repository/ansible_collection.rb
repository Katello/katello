require 'pulp_ansible_client'

module Katello
  module Pulp3
    class Repository
      class AnsibleCollection < ::Katello::Pulp3::Repository
        def remote_options
          if root.url.blank?
            super
          else
            common_remote_options.merge(url: root.url.chomp("/"), requirements_file: root.ansible_collection_requirements.blank? ? nil : root.ansible_collection_requirements)
          end
        end

        def distribution_options(path)
          {
            base_path: path,
            repository_version: repo.version_href,
            name: "#{generate_backend_object_name}"
          }
        end

        def partial_repo_path
          "/pulp_ansible/galaxy/#{repo.relative_path}/api/v2/collections"
        end

        def mirror_remote_options
          {
          }
        end
      end
    end
  end
end
