require "pulpcore_client"
# rubocop:disable ClassLength

module Katello
  module Pulp3
    class Repository
      include Katello::Util::HttpProxy

      attr_accessor :repo
      attr_accessor :smart_proxy
      delegate :root, to: :repo
      delegate :pulp3_api, to: :smart_proxy

      COPY_UNIT_PAGE_SIZE = 10_000

      def initialize(repo, smart_proxy)
        @repo = repo
        @smart_proxy = smart_proxy
      end

      def partial_repo_path
        fail NotImplementedError
      end

      def with_mirror_adapter
        if smart_proxy.pulp_master?
          return self
        else
          return RepositoryMirror.new(self)
        end
      end

      def self.api(smart_proxy)
        api_class = RepositoryTypeManager.find_by(:pulp3_service_class, self).pulp3_api_class
        api_class ? api_class.new(smart_proxy) : Katello::Pulp3::Api::Core.new(smart_proxy)
      end

      def core_api
        Katello::Pulp3::Api::Core.new(smart_proxy)
      end

      def api
        @api ||= self.class.api(smart_proxy)
      end

      def content_service
        Katello::Pulp3::Content
      end

      def create_remote
        remote_file_data = api.class.remote_class.new(remote_options)
        response = api.remotes_api.create(remote_file_data)
        repo.update_attributes!(:remote_href => response.pulp_href)
      end

      def update_remote
        href = repo.remote_href
        if remote_options[:url].blank?
          if href
            repo.update_attributes(remote_href: nil)
            delete_remote href
          end
        else
          if href
            remote_partial_update
          else
            create_remote
          end
        end
      end

      def remote_partial_update
        api.remotes_api.partial_update(repo.remote_href, remote_options)
      end

      def delete_remote(href = repo.remote_href)
        api.remotes_api.delete(href) if href
      end

      def self.instance_for_type(repo, smart_proxy)
        Katello::RepositoryTypeManager.repository_types[repo.root.content_type].pulp3_service_class.new(repo, smart_proxy)
      end

      def should_purge_empty_contents?
        false
      end

      def generate_backend_object_name
        "#{root.label}-#{repo.id}#{rand(9999)}"
      end

      def repository_reference
        RepositoryReference.find_by(:root_repository_id => repo.root_id, :content_view_id => repo.content_view.id)
      end

      def distribution_reference
        DistributionReference.find_by(:repository_id => repo.id)
      end

      def create_mirror_entities
        RepositoryMirror.new(self).create_entities
      end

      def refresh_mirror_entities
        RepositoryMirror.new(self).refresh_entities
      end

      def mirror_needs_updates?
        RepositoryMirror.new(self).needs_updates?
      end

      def refresh_if_needed
        tasks = []
        tasks << update_remote if remote_needs_updates?
        tasks << update_distribution if distribution_needs_update?
        tasks.compact
      end

      def get_remote(href = repo.remote_href)
        api.remotes_api.read(href)
      end

      def remote_needs_updates?
        if repo.remote_href
          remote = get_remote
          computed = compute_remote_options
          computed.keys.any? { |key| remote.send(key) != computed[key] }
        elsif repo.url
          true
        else
          false
        end
      end

      def get_distribution(href = distribution_reference.href)
        api.get_distribution(href)
      end

      def distribution_needs_update?
        if distribution_reference
          expected = distribution_options(relative_path).except(:name).compact
          actual = get_distribution.to_hash
          expected != actual.slice(*expected.keys)
        elsif repo.environment
          true
        else
          false
        end
      end

      def compute_remote_options(computed_options = remote_options)
        [:client_cert, :client_key, :ca_cert].each do |key|
          computed_options[key] = Digest::SHA256.hexdigest(computed_options[key].chomp) if computed_options[key]
        end
        computed_options.except(:name)
      end

      def create
        unless repository_reference
          response = api.repositories_api.create(
            name: generate_backend_object_name)
          RepositoryReference.create!(
           root_repository_id: repo.root_id,
           content_view_id: repo.content_view.id,
           repository_href: response.pulp_href)
          response
        end
      end

      def update
        api.repositories_api.update(repository_reference.try(:repository_href), name: generate_backend_object_name)
      end

      def list(options)
        api.repositories_api.list(options).results
      end

      def delete(href = repository_reference.try(:repository_href))
        repository_reference.try(:destroy)
        api.repositories_api.delete(href) if href
      end

      def sync
        repository_sync_url_data = api.class.client_module::RepositorySyncURL.new(remote: repo.remote_href, mirror: repo.root.mirror_on_sync)
        [api.repositories_api.sync(repository_reference.repository_href, repository_sync_url_data)]
      end

      def create_publication
        publication_data = api.class.publication_class.new(repository_version: repo.version_href)
        api.publications_api.create(publication_data)
      end

      def relative_path
        repo.relative_path.sub(/^\//, '')
      end

      def refresh_distributions
        dist_ref = distribution_reference
        if dist_ref
          update_distribution
        else
          create_distribution(relative_path)
        end
      end

      def create_distribution(path)
        distribution_data = api.class.distribution_class.new(distribution_options(path))
        api.distributions_api.create(distribution_data)
      end

      def lookup_distributions(args)
        api.distributions_api.list(args).results
      end

      def update_distribution
        if distribution_reference
          options = distribution_options(relative_path).except(:name)
          api.distributions_api.partial_update(distribution_reference.href, options)
        end
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

      def create_version(options = {})
        api.repositories_api.modify(repository_reference.repository_href, options)
      end

      def save_distribution_references(hrefs)
        hrefs.each do |href|
          path = api.get_distribution(href)&.base_path
          unless distribution_reference
            DistributionReference.create!(path: path, href: href, repository_id: repo.id)
          end
        end
      end

      def delete_distributions
        if (dist_ref = distribution_reference)
          api.delete_distribution(dist_ref.href)
          dist_ref.destroy!
        end
      end

      def delete_distributions_by_path
        path = relative_path
        dists = lookup_distributions(base_path: path)

        task = api.delete_distribution(dists.first.pulp_href) if dists.first
        Katello::Pulp3::DistributionReference.where(:path => path).destroy_all
        task
      end

      def common_remote_options
        remote_options = {
          tls_validation: root.verify_ssl_on_sync,
          name: generate_backend_object_name,
          url: root.url,
          proxy_url: root.http_proxy&.full_url
        }
        remote_options[:url] = root.url unless root.url.blank?
        if root.upstream_username && root.upstream_password
          remote_options.merge!(username: root.upstream_username,
                               password: root.upstream_password)
        end
        remote_options.merge!(ssl_remote_options)
      end

      def ssl_remote_options
        if root.redhat? && Katello::Resources::CDN::CdnResource.redhat_cdn?(root.url)
          {
            client_cert: root.product.certificate,
            client_key: root.product.key,
            ca_cert: Katello::Repository.feed_ca_cert(root.url)
          }
        elsif root.custom?
          {
            client_cert: root.ssl_client_cert&.content,
            client_key: root.ssl_client_key&.content,
            ca_cert: root.ssl_ca_cert&.content
          }
        else
          {}
        end
      end

      def lookup_version(href)
        api.repository_versions_api.read(href) if href
      rescue api.api_exception_class => e
        Rails.logger.error "Exception when calling repository_versions_api->read: #{e}"
        nil
      end

      def lookup_publication(href)
        api.publications_api.read(href) if href
      rescue api.api_exception_class => e
        Rails.logger.error "Exception when calling publications_api->read: #{e}"
        nil
      end

      def remove_content(content_units)
        if repo.root.content_type == "docker"
          api.repositories_api.remove(repository_reference.repository_href, content_units: content_units.map(&:pulp_id))
        else
          api.repositories_api.modify(repository_reference.repository_href, remove_content_units: content_units.map(&:pulp_id))
        end
      end

      def add_content(content_unit_href)
        content_unit_href = [content_unit_href] unless content_unit_href.is_a?(Array)
        api.repositories_api.modify(repository_reference.repository_href, add_content_units: content_unit_href)
      end

      def unit_keys(uploads)
        uploads.map do |upload|
          upload.except('id')
        end
      end
    end
  end
end
