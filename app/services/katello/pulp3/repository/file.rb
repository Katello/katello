module Katello
  module Pulp3
    class Repository
      class File < ::Katello::Pulp3::Repository
        def create_remote
          response = pulp3_api.remotes_file_file_create(Zest::FileRemote.new(remote_options))
          repo.update_attributes!(:remote_href => response._href)
        end

        def remote_options
          #TODO: move to user specifying PULP_MANIFEST
          common_remote_options.merge(url: root.url + '/PULP_MANIFEST')
        end

        def update_remote
          pulp3_api.remotes_file_file_partial_update(repo.remote_href, remote_options)
        end

        def delete_remote(href = repo.remote_href)
          pulp3_api.remotes_file_file_delete(href) if href
        end

        def list_remotes(args)
          pulp3_api.remotes_file_file_list(args).results
        end

        def sync
          [pulp3_api.remotes_file_file_sync(repo.remote_href, repository: repository_reference.repository_href)]
        end

        def create_publisher
          unless repository_reference.publisher_href
            response = pulp3_api.publishers_file_file_create(:name => backend_object_name)
            repository_reference.update_attributes!(:publisher_href => response._href)
          end
        end

        def list_publishers(args)
          pulp3_api.publishers_file_file_list(args).results
        end

        def update_publisher
          pulp3_api.publishers_file_file_update(repository_reference.publisher_href, name: backend_object_name)
        end

        def delete_publisher(href = repository_reference.publisher_href)
          pulp3_api.publishers_file_file_delete(href)
        end

        def create_publication
          pulp3_api.publishers_file_file_publish(repository_reference.publisher_href, repository_version: repo.version_href)
        end
      end
    end
  end
end
