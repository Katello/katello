require 'pulp_ansible_client'

module Katello
  module Pulp3
    class Repository
      class AnsibleCollection < ::Katello::Pulp3::Repository
        def copy_content_for_source(source_repository, _options = {})
          copy_units_by_href(source_repository.ansible_collections.pluck(:pulp_id))
        end

        def remote_options
          common_remote_options.merge(url: root.url.chomp('/').concat('/'),
                                      requirements_file: root.ansible_collection_requirements.blank? ? nil : root.ansible_collection_requirements,
                                      auth_url: root.ansible_collection_auth_url,
                                      token: root.ansible_collection_auth_token,
                                      tls_validation: root.verify_ssl_on_sync)
        end

        def distribution_options(path)
          {
            base_path: path,
            repository_version: repo.version_href,
            name: "#{generate_backend_object_name}",
          }
        end

        def partial_repo_path
          "/pulp_ansible/galaxy/#{repo.relative_path}/api/"
        end

        def mirror_remote_options
          {
          }
        end
      end
    end
  end
end
