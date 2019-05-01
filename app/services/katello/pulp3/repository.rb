require "pulpcore_client"

module Katello
  module Pulp3
    class Repository
      attr_accessor :repo, :input
      attr_accessor :smart_proxy
      delegate :root, to: :repo
      delegate :pulp3_api, to: :smart_proxy

      def initialize(repo, smart_proxy)
        @repo = repo
        @smart_proxy = smart_proxy
      end

      def create_remote
        fail NotImplementedError
      end

      def remote_options
        fail NotImplementedError
      end

      def update_remote
        fail NotImplementedError
      end

      def sync
        fail NotImplementedError
      end

      def create_publisher
        fail NotImplementedError
      end

      def create_publication
        fail NotImplementedError
      end

      def delete_publication
        fail NotImplementedError
      end

      def self.instance_for_type(repo, smart_proxy)
        Katello::RepositoryTypeManager.repository_types[repo.root.content_type].pulp3_service_class.new(repo, smart_proxy)
      end

      def backend_object_name
        "#{root.label}-#{repo.id}#{rand(9999)}"
      end

      def repository_reference
        RepositoryReference.find_by(:root_repository_id => repo.root_id, :content_view_id => repo.content_view.id)
      end

      def distribution_reference(path)
        DistributionReference.find_by(:path => path)
      end

      def create
        unless repository_reference
          response = pulp3_api.repositories_create(
            name: backend_object_name)
          RepositoryReference.create!(
           root_repository_id: repo.root_id,
           content_view_id: repo.content_view.id,
           repository_href: response._href)
          response
        end
      end

      def update
        pulp3_api.repositories_update(repository_reference.repository_href, name: backend_object_name)
      end

      def list(args)
        pulp3_api.repositories_list(args).results
      end

      def delete(href = repository_reference.repository_href)
        response = pulp3_api.repositories_delete(href)
        repository_reference.destroy if repository_reference
        response
      end

      def update_distribution(path)
        distribution_reference = distribution_reference(path)
        pulp3_api.distributions_partial_update(distribution_reference.href, publication: repo.publication_href)
      end

      def refresh_distributions
        paths.map do |prefix, path|
          dist_ref = distribution_reference(path)
          if dist_ref
            if prefix == :http
              if repo.root.unprotected
                update_distribution(path)
              else
                result = delete_distribution(dist_ref.href)
                dist_ref.destroy
                result
              end
            else
              update_distribution(path)
            end
          else
            if prefix == :http
              create_distribution(prefix, path) if repo.root.unprotected
            else
              create_distribution(prefix, path)
            end
          end
        end
      end

      def create_version
        pulp3_api.repositories_versions_create(repository_reference.repository_href, {})
      end

      def paths
        {
          https: "https/#{repo.relative_path}",
          http: "http/#{repo.relative_path}"
        }
      end

      private def delete_distribution(href)
        pulp3_api.distributions_delete(href)
      end

      def lookup_distributions(args)
        pulp3_api.distributions_list(args).results
      end

      def get_distribution(href)
        pulp3_api.distributions_read(href)
      rescue Zest::ApiError => e
        raise e if e.code != 404
        nil
      end

      def delete_distributions
        paths.values.each do |path|
          dists = lookup_distributions(base_path: path.sub(/^\//, ''))
          delete_distribution(dists.first._href) if dists.first
          distribution_reference = distribution_reference(path)
          distribution_reference.destroy if distribution_reference
        end
      end

      def save_distribution_references(hrefs)
        hrefs.each do |href|
          path = get_distribution(href)&.base_path
          unless distribution_reference(path)
            DistributionReference.create!(path: path, href: href, root_repository_id: repo.root.id)
          end
        end
      end

      def create_distribution(prefix, path)
        path = path.sub(/^\//, '') #remove leading / if present
        distribution_data = PulpcoreClient::Distribution.new(
          base_path: repo.relative_path,
          publication: repo.publication_href,
          name: "#{prefix}_#{backend_object_name}")
        pulp3_api.distributions_create(distribution_data)
      end

      def common_remote_options
        remote_options = {
          validate: true,
          ssl_validation: root.verify_ssl_on_sync,
          name: backend_object_name,
          url: root.url
        }
        if root.upstream_username && root.upstream_password
          remote_options.merge(username: root.upstream_username,
                               password: root.upstream_password)
        end
        remote_options.merge(ssl_remote_options)
      end

      def ssl_remote_options
        if root.redhat? && Katello::Resources::CDN::CdnResource.redhat_cdn?(root.url)
          {
            ssl_client_certificate: root.product.certificate,
            ssl_client_key: root.product.key,
            ssl_ca_certificate: Katello::Repository.feed_ca_cert(root.url)
          }
        elsif root.custom?
          {
            ssl_client_certificate: root.ssl_client_cert&.content,
            ssl_client_key: root.ssl_client_key&.content,
            ssl_ca_certificate: root.ssl_ca_cert&.content
          }
        else
          {}
        end
      end
    end
  end
end
