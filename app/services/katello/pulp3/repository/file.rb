require "pulp_file_client"
gem "pulp_file_client", path: "/home/projects/pulp_file-client"

module Katello
  module Pulp3
    class Repository
      class File < ::Katello::Pulp3::Repository
        def create_remote
          remote_file_data = PulpFileClient::FileRemote.new(remote_options)
          response = pulp3_api.remotes_file_file_create(remote_file_data)
          repo.update_attributes!(:remote_href => response._href)
        end

        def remote_options
          #TODO: move to user specifying PULP_MANIFEST
          common_remote_options.merge(url: root.url + '/PULP_MANIFEST')
        end

        def update_remote
          if remote_options[:url].blank?
            if repo.remote_href
              pulp3_api.remotes_file_file_delete(repo.remote_href)
            else
              create_remote
            end
          else
            pulp3_api.remotes_file_file_partial_update(repo.remote_href, remote_options)
          end
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
          publication_data = PulpFileClient::FilePublication.new(
            repository: repository_reference.repository_href)
          pulp3_api.publications_file_file_create(publication_data)
        end
      end
    end
  end
end
