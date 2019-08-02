require "pulpcore_client"

module Katello
  module Pulp3
    class Repository
      include Katello::Util::HttpProxy

      attr_accessor :repo, :input
      attr_accessor :smart_proxy
      delegate :root, to: :repo
      delegate :pulp3_api, to: :smart_proxy

      COPY_UNIT_PAGE_SIZE = 10_000

      def initialize(repo, smart_proxy)
        @repo = repo
        @smart_proxy = smart_proxy
      end

      def api_exception_class
        fail NotImplementedError
      end

      def remote_class
        fail NotImplementedError
      end

      def publications_api
        fail NotImplementedError
      end

      def publication_class
        fail NotImplementedError
      end

      def distribution_class
        fail NotImplementedError
      end

      def distributions_api_class
        fail NotImplementedError
      end

      def distribution_options
        fail NotImplementedError
      end

      def remote_options
        fail NotImplementedError
      end

      def self.api_client(_smart_proxy)
        fail NotImplementedError
      end

      def api_client
        self.class.api_client(smart_proxy)
      end

      def create_remote
        remote_file_data = remote_class.new(remote_options)
        response = remotes_api.create(remote_file_data)
        repo.update_attributes!(:remote_href => response._href)
      end

      def update_remote
        if remote_options[:url].blank?
          if repo.remote_href
            href = repo.remote_href
            repo.update_attributes(remote_href: nil)
            delete_remote href
          end
        else
          if repo.remote_href?
            remote_partial_update
          else
            create_remote
          end
        end
      end

      def remote_partial_update
        remotes_api.partial_update(repo.remote_href, remote_options)
      end

      def delete_remote(href = repo.remote_href)
        remotes_api.delete(href) if href
      end

      def list_remotes(args)
        remotes_api.list(args).results
      end

      def core_api_client
        PulpcoreClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpcoreClient::Configuration))
      end

      def repositories_api
        PulpcoreClient::RepositoriesApi.new(core_api_client)
      end

      def repository_versions_api
        PulpcoreClient::RepositoriesVersionsApi.new(core_api_client)
      end

      def self.instance_for_type(repo, smart_proxy)
        Katello::RepositoryTypeManager.repository_types[repo.root.content_type].pulp3_service_class.new(repo, smart_proxy)
      end

      def should_purge_empty_contents?
        false
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
          response = repositories_api.create(
            name: backend_object_name)
          RepositoryReference.create!(
           root_repository_id: repo.root_id,
           content_view_id: repo.content_view.id,
           repository_href: response._href)
          response
        end
      end

      def update
        repositories_api.update(repository_reference.repository_href, name: backend_object_name)
      end

      def list(args)
        repositories_api.list(args).results
      end

      def delete(href = repository_reference.try(:repository_href))
        repository_reference.try(:destroy)
        if href
          response = repositories_api.delete(href)
          response
        end
      end

      def sync
        [remotes_api.sync(repo.remote_href, repository: repository_reference.repository_href)]
      end

      def create_publication
        publication_data = publication_class.new(repository_version: repo.version_href)
        publications_api.create(publication_data)
      end

      def refresh_distributions
        path = repo.relative_path.sub(/^\//, '')
        dist_ref = distribution_reference(path)
        if dist_ref
          update_distribution(path)
        else
          create_distribution(path)
        end
      end

      def create_distribution(path)
        distribution_data = distribution_class.new(distribution_options(path))
        distributions_api.create(distribution_data)
      end

      def delete_distribution(href)
        distributions_api.delete(href)
      rescue api_exception_class => e
        raise e if e.code != 404
        nil
      end

      def lookup_distributions(args)
        distributions_api.list(args).results
      end

      def update_distribution(path)
        distribution_reference = distribution_reference(path)
        if distribution_reference
          options = distribution_options(path).except(:name, :base_path)
          distributions_api.partial_update(distribution_reference.href, options)
        end
      end

      def get_distribution(href)
        distributions_api.read(href)
      rescue api_exception_class => e
        raise e if e.code != 404
        nil
      end

      def create_version(options = {})
        repository_versions_api.create(repository_reference.repository_href, options)
      end

      def copy_units_by_href(unit_hrefs)
        tasks = []
        unit_hrefs.each_slice(COPY_UNIT_PAGE_SIZE) do |slice|
          tasks << create_version(:add_content_units => slice)
        end
        tasks
      end

      def copy_version(from_repository)
        create_version(:base_version => from_repository.version_href)
      end

      def save_distribution_references(hrefs)
        hrefs.each do |href|
          path = get_distribution(href)&.base_path
          unless distribution_reference(path)
            DistributionReference.create!(path: path, href: href, root_repository_id: repo.root.id)
          end
        end
      end

      def delete_distributions
        path = repo.relative_path.sub(/^\//, '')
        dists = lookup_distributions(base_path: path)
        delete_distribution(dists.first._href) if dists.first
        dist_ref = distribution_reference(path)
        dist_ref.destroy! if dist_ref
      end

      def common_remote_options
        remote_options = {
          ssl_validation: root.verify_ssl_on_sync,
          name: backend_object_name,
          url: root.url,
          proxy_url: root.http_proxy&.full_url
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

      def lookup_version(href)
        repository_versions_api.read(href)
      rescue PulpcoreClient::ApiError => e
        Rails.logger.error "Exception when calling RepositoriesApi->repositories_versions_read: #{e}"
        nil
      end

      def remove_content(content_units)
        data = PulpcoreClient::RepositoryVersionCreate.new(
          remove_content_units: content_units.map(&:pulp_id))
        repository_versions_api.create(repository_reference.repository_href, data)
      end
    end
  end
end
