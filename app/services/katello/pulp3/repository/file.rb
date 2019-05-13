require 'pulp_file_client'

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
          if root.url.blank?
            common_remote_options.delete(:url)
            common_remote_options
          else
            common_remote_options.merge(url: root.url + '/PULP_MANIFEST')
          end
        end

        def update_remote
          if remote_options[:url].blank?
            if repo.remote_href
              href = repo.remote_href
              repo.update_attributes(remote_href: nil)
              pulp3_api.remotes_file_file_delete(href)
            end
          else
            if repo.remote_href?
              pulp3_api.remotes_file_file_partial_update(repo.remote_href, remote_options)
            else
              create_remote
            end
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

        def create_publication
          publication_data = ::PulpFileClient::FilePublication.new(
            repository_version: repo.version_href)
          pulp3_api.publications_file_file_create(publication_data)
        end

        def create_distribution(path)
          distribution_data = PulpFileClient::FileDistribution.new(
            base_path: path,
            publication: repo.publication_href,
            name: "#{backend_object_name}")
          pulp3_api.distributions_file_file_create(distribution_data)
        end

        def delete_distributions
          path = repo.relative_path.sub(/^\//, '')
          dists = lookup_distributions(base_path: path)
          delete_distribution(dists.first._href) if dists.first
          dist_ref = distribution_reference(path)
          dist_ref.destroy! if dist_ref
        end

        private def delete_distribution(href)
          pulp3_api.distributions_file_file_delete(href)
        end

        def lookup_distributions(args)
          pulp3_api.distributions_file_file_list(args).results
        end

        def update_distribution(path)
          distribution_reference = distribution_reference(path)
          if distribution_reference
            pulp3_api.distributions_file_file_partial_update(distribution_reference.href, publication: repo.publication_href)
          end
        end

        def get_distribution(href)
          pulp3_api.distributions_file_file_read(href)
        rescue PulpFileClient::ApiError => e
          raise e if e.code != 404
          nil
        end
      end
    end
  end
end
