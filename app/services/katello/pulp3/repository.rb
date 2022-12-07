# rubocop:disable Metrics/ClassLength
require "pulpcore_client"
module Katello
  module Pulp3
    class Repository
      include Katello::Util::HttpProxy
      include Katello::Pulp3::ServiceCommon
      attr_accessor :repo
      attr_accessor :smart_proxy
      delegate :root, to: :repo
      delegate :pulp3_api, to: :smart_proxy

      COPY_UNIT_PAGE_SIZE = 10_000

      def initialize(repo, smart_proxy)
        @repo = repo
        @smart_proxy = smart_proxy
      end

      def self.version_href?(href)
        /.*\/versions\/\d*\//.match(href)
      end

      def self.publication_href?(href)
        href.include?('/publications/')
      end

      def partial_repo_path
        fail NotImplementedError
      end

      def with_mirror_adapter
        if smart_proxy.pulp_primary?
          return self
        else
          return RepositoryMirror.new(self)
        end
      end

      def self.api(smart_proxy, repository_type_label)
        repo_type = RepositoryTypeManager.enabled_repository_types[repository_type_label]
        repo_type.pulp3_api(smart_proxy)
      end

      def core_api
        Katello::Pulp3::Api::Core.new(smart_proxy)
      end

      def api
        @api ||= self.class.api(smart_proxy, repo.content_type)
      end

      def published?
        !repo.publication_href.nil?
      end

      def repair(repository_version_href)
        data = api.repair_class.new
        api.repository_versions_api.repair(repository_version_href, data)
      end

      def skip_types
        nil
      end

      def content_service
        Katello::Pulp3::Content
      end

      def create_remote
        response = super
        repo.update!(:remote_href => response.pulp_href)
      end

      def update_remote
        href = repo.remote_href
        if remote_options[:url].blank?
          if href
            repo.update(remote_href: nil)
            delete_remote(href: href)
          end
        else
          if href
            remote_partial_update
          else
            create_remote
            return nil #return nil, as create isn't async
          end
        end
      end

      def remote_partial_update
        if remote_options[:url]&.start_with?('uln')
          api.remotes_uln_api.partial_update(repo.remote_href, remote_options)
        else
          api.remotes_api.partial_update(repo.remote_href, remote_options)
        end
      end

      def delete_remote(options = {})
        options[:href] ||= repo.remote_href
        ignore_404_exception { remote_options[:url]&.start_with?('uln') ? api.remotes_uln_api.delete(options[:href]) : api.remotes_api.delete(options[:href]) } if options[:href]
      end

      def self.instance_for_type(repo, smart_proxy)
        Katello::RepositoryTypeManager.enabled_repository_types[repo.root.content_type].pulp3_service_class.new(repo, smart_proxy)
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

      def refresh_if_needed
        tasks = []
        tasks << update_remote #always update remote
        tasks << update_distribution if distribution_needs_update?
        tasks.compact
      end

      def get_remote(href = repo.remote_href)
        repo.url&.start_with?('uln') ? api.remotes_uln_api.read(href) : api.remotes_api.read(href)
      end

      def get_distribution(href = distribution_reference.href)
        api.get_distribution(href)
      end

      def distribution_needs_update?
        if distribution_reference
          expected = secure_distribution_options(relative_path).except(:name).compact
          actual = get_distribution&.to_hash || {}
          expected != actual.slice(*expected.keys)
        elsif repo.environment
          true
        else
          false
        end
      end

      def compute_remote_options(computed_options = remote_options)
        computed_options.except(:name, :client_key)
      end

      def create(force = false)
        if force || !repository_reference
          response = api.repositories_api.create(create_options)
          RepositoryReference.where(
            root_repository_id: repo.root_id,
            content_view_id: repo.content_view.id).destroy_all
          RepositoryReference.where(
            root_repository_id: repo.root_id,
            content_view_id: repo.content_view.id,
            repository_href: response.pulp_href).create!
          response
        end
      end

      def update
        api.repositories_api.update(repository_reference.try(:repository_href), create_options)
      end

      def list(options)
        api.repositories_api.list(options).results
      end

      def read
        api.repositories_api.read(repository_reference.try(:repository_href))
      end

      def delete_repository(repo_reference = repository_reference)
        href = repo_reference.try(:repository_href)
        repo_reference.try(:destroy)
        ignore_404_exception { api.repositories_api.delete(href) } if href
      end

      def sync(options = {})
        repository_sync_url_data = api.repository_sync_url_class.new(sync_url_params(options))
        [api.repositories_api.sync(repository_reference.repository_href, repository_sync_url_data)]
      end

      def sync_url_params(_sync_options)
        params = {remote: repo.remote_href, mirror: repo.root.mirroring_policy == Katello::RootRepository::MIRRORING_POLICY_CONTENT}
        params[:skip_types] = skip_types if (skip_types && repo.root.mirroring_policy != Katello::RootRepository::MIRRORING_POLICY_COMPLETE)
        params
      end

      def create_publication
        publication_data = api.publication_class.new(publication_options(repo.version_href))
        api.publications_api.create(publication_data)
      end

      def publication_options(repository_version)
        {
          repository_version: repository_version
        }
      end

      def relative_path
        repo.relative_path.sub(/^\//, '')
      end

      def refresh_distributions
        if repo.docker?
          dist = lookup_distributions(base_path: repo.container_repository_name).first
        else
          dist = lookup_distributions(base_path: repo.relative_path).first
        end
        dist_ref = distribution_reference

        if dist && !dist_ref
          save_distribution_references([dist.pulp_href])
          return update_distribution
        end

        if dist && dist_ref
          # If the saved distribution reference is wrong, delete it and use the existing distribution
          if dist.pulp_href != dist_ref.href
            dist_ref.destroy
            save_distribution_references([dist.pulp_href])
          end
          return update_distribution
        end

        # Since we got this far, we need to create a new distribution
        # Note: the distribution reference can't be saved yet because distribution creation is async
        begin
          create_distribution(relative_path)
        rescue api.client_module::ApiError => e
          # Now it seems there is a distribution. Fetch it and save the reference.
          if e.message.include?("\"base_path\":[\"This field must be unique.\"]") ||
              e.message.include?("\"base_path\":[\"Overlaps with existing distribution\"")
            dist = lookup_distributions(base_path: repo.relative_path).first
            save_distribution_references([dist.pulp_href])
            return update_distribution
          else
            raise e
          end
        end
      end

      def create_distribution(path)
        distribution_data = api.distribution_class.new(secure_distribution_options(path))
        unless ::Katello::RepositoryTypeManager.find(repo.content_type).pulp3_skip_publication
          fail_missing_publication(distribution_data.publication)
        end
        api.distributions_api.create(distribution_data)
      end

      def lookup_distributions(args)
        api.distributions_api.list(args).results
      end

      def read_distribution(href = distribution_reference.href)
        ignore_404_exception { api.distributions_api.read(href) }
      end

      def update_distribution
        if distribution_reference
          options = secure_distribution_options(relative_path).except(:name)
          unless ::Katello::RepositoryTypeManager.find(repo.content_type).pulp3_skip_publication
            fail_missing_publication(options[:publication])
          end
          distribution_reference.update(:content_guard_href => options[:content_guard])
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

      def copy_all(source_repository, options = {})
        tasks = []
        if options[:remove_all]
          tasks << api.repositories_api.modify(repository_reference.repository_href, remove_content_units: ['*'])
        end

        if options[:mirror] && api.class.respond_to?(:add_remove_content_class)
          data = api.class.add_remove_content_class.new(
                    base_version: source_repository.version_href)

          tasks << api.repositories_api.modify(repository_reference.repository_href, data)
          tasks
        elsif api.respond_to? :copy_api
          data = api.class.copy_class.new
          data.config = [{
            source_repo_version: source_repository.version_href,
            dest_repo: repository_reference.repository_href
          }]
          tasks << api.copy_api.copy_content(data)
          tasks
        else
          copy_content_for_source(source_repository)
        end
      end

      def copy_version(from_repository)
        create_version(:base_version => from_repository.version_href)
      end

      def version_zero?
        repo.version_href.ends_with?('/versions/0/')
      end

      def delete_version
        ignore_404_exception { api.repository_versions_api.delete(repo.version_href) } unless version_zero?
      end

      def create_version(options = {})
        api.repositories_api.modify(repository_reference.repository_href, options)
      end

      def save_distribution_references(hrefs)
        hrefs.each do |href|
          pulp3_distribution_data = api.get_distribution(href)
          path, content_guard_href = pulp3_distribution_data&.base_path, pulp3_distribution_data&.content_guard
          if distribution_reference
            found_distribution = read_distribution(distribution_reference.href)
            unless found_distribution
              distribution_reference.destroy
            end
          end
          unless distribution_reference
            # Ensure that duplicates won't be created in the case of a race condition
            DistributionReference.where(path: path, href: href, repository_id: repo.id, content_guard_href: content_guard_href).first_or_create!
          end
        end
      end

      def delete_distributions
        if (dist_ref = distribution_reference)
          ignore_404_exception { api.delete_distribution(dist_ref.href) }
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
          proxy_url: root.http_proxy&.url,
          proxy_username: root.http_proxy&.username,
          proxy_password: root.http_proxy&.password,
          total_timeout: Setting[:sync_total_timeout],
          connect_timeout: Setting[:sync_connect_timeout_v2],
          sock_connect_timeout: Setting[:sync_sock_connect_timeout],
          sock_read_timeout: Setting[:sync_sock_read_timeout],
          rate_limit: Setting[:download_rate_limit]
        }
        remote_options[:url] = root.url unless root.url.blank?
        remote_options[:download_concurrency] = root.download_concurrency unless root.download_concurrency.blank?
        remote_options.merge!(username: root&.upstream_username,
                              password: root&.upstream_password)
        remote_options.merge!(ssl_remote_options)
      end

      def mirror_remote_options
        options = {}
        if Katello::RootRepository::CONTENT_ATTRIBUTE_RESTRICTIONS[:download_policy].include?(repo.content_type)
          options[:policy] = smart_proxy.download_policy
          if smart_proxy.download_policy == SmartProxy::DOWNLOAD_INHERIT
            options[:policy] = repo.root.download_policy
          end
        end
        options
      end

      def create_options
        { name: generate_backend_object_name }.merge!(specific_create_options)
      end

      def specific_create_options
        {}
      end

      def secure_distribution_options(path)
        secured_distribution_options = {}
        if root.unprotected
          secured_distribution_options[:content_guard] = nil
        else
          secured_distribution_options[:content_guard] = ::Katello::Pulp3::ContentGuard.first.pulp_href
        end
        secured_distribution_options.merge!(distribution_options(path))
      end

      def ssl_remote_options
        if root.redhat? && root.cdn_configuration.redhat_cdn?
          {
            client_cert: root.product.certificate,
            client_key: root.product.key,
            ca_cert: Katello::Repository.feed_ca_cert(root.url)
          }
        elsif root.redhat? && root.cdn_configuration.network_sync?
          {
            client_cert: root.cdn_configuration.ssl_cert,
            client_key: root.cdn_configuration.ssl_key,
            ca_cert: root.cdn_configuration.ssl_ca
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

      def repository_import_content(artifact_href, options = {})
        ostree_import = PulpOstreeClient::OstreeRepoImport.new
        ostree_import.artifact = artifact_href
        ostree_import.repository_name = options[:ostree_repository_name]
        ostree_import.ref = options[:ostree_ref]
        api.repositories_api.import_commits(repository_reference.repository_href, ostree_import)
      end

      def add_content(content_unit_href, remove_all_units = false)
        content_unit_href = [content_unit_href] unless content_unit_href.is_a?(Array)
        if remove_all_units
          api.repositories_api.modify(repository_reference.repository_href, remove_content_units: ['*'])
          api.repositories_api.modify(repository_reference.repository_href, add_content_units: content_unit_href)
        else
          api.repositories_api.modify(repository_reference.repository_href, add_content_units: content_unit_href)
        end
      end

      def add_content_for_repo(repository_href, content_unit_href)
        content_unit_href = [content_unit_href] unless content_unit_href.is_a?(Array)
        api.repositories_api.modify(repository_href, add_content_units: content_unit_href)
      end

      def unit_keys(uploads)
        uploads.map do |upload|
          upload.except('id')
        end
      end

      def retain_package_versions_count
        return 0 if root.retain_package_versions_count.nil? || root.using_mirrored_content?
        root.retain_package_versions_count.to_i
      end

      def fail_missing_publication(publication_href)
        unless lookup_publication(publication_href)
          fail _("The repository's publication is missing. Please run a 'complete sync' on %s." % repo.name)
        end
      end
    end
  end
end
