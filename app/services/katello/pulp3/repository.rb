require "pulpcore_client"
# rubocop:disable ClassLength

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

      def content_service
        Katello::Pulp3::Content
      end

      def self.api_client(_smart_proxy)
        fail NotImplementedError
      end

      def api_client
        self.class.api_client(smart_proxy)
      end

      def distribution_mirror_options(path, options = {})
        ret = {
          base_path: path,
          name: "#{backend_object_name}"
        }
        ret[:publication] = options[:publication] if options.key? :publication
        ret[:repository_version] = options[:repository_version] if options.key? :repository_version
        ret
      end

      def mirror_remote_options
        common_mirror_remote_options
      end

      def create_mirror_remote
        remote_file_data = remote_class.new(mirror_remote_options)
        remotes_api.create(remote_file_data)
      end

      def create_remote
        remote_file_data = remote_class.new(remote_options)
        response = remotes_api.create(remote_file_data)
        repo.update_attributes!(:remote_href => response._href)
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

      def uploads_api
        PulpcoreClient::UploadsApi.new(core_api_client)
      end

      def upload_class
        PulpcoreClient::Upload
      end

      def self.instance_for_type(repo, smart_proxy)
        Katello::RepositoryTypeManager.repository_types[repo.root.content_type].pulp3_service_class.new(repo, smart_proxy)
      end

      def should_purge_empty_contents?
        false
      end

      def backend_object_name
        if @smart_proxy.pulp_master?
          "#{root.label}-#{repo.id}#{rand(9999)}"
        else
          # this is a capsule. Create repos in pulp3 instance with the name as this repo's pulp_id
          repo.pulp_id
        end
      end

      def repository_reference
        RepositoryReference.find_by(:root_repository_id => repo.root_id, :content_view_id => repo.content_view.id)
      end

      def distribution_reference(path)
        DistributionReference.find_by(:path => path)
      end

      def refresh_mirror_entities
        href = mirror_remote_href
        if href
          [remotes_api.partial_update(href, mirror_remote_options)]
        else
          create_mirror_remote
          []
        end
      end

      def mirror_needs_updates?
        remote = fetch_remote
        return true if remote.blank?
        options = compute_mirror_remote_options
        options.keys.any? { |key| remote.send(key) != options[key] }
      end

      def compute_mirror_remote_options
        computed_options = mirror_remote_options
        [:ssl_client_certificate, :ssl_client_key, :ssl_ca_certificate].each do |key|
          computed_options[key] = Digest::SHA256.hexdigest(computed_options[key].chomp)
        end
        computed_options
      end

      def create_mirror_entities
        create_mirror
        create_mirror_remote unless mirror_remote_href
      end

      def create_mirror
        repositories_api.create(name: backend_object_name)
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

      def update_mirror
        repositories_api.update(mirror_repository_href, name: backend_object_name)
      end

      def update
        repositories_api.update(repository_reference.try(:repository_href), name: backend_object_name)
      end

      def list(options)
        repositories_api.list(options).results
      end

      def self.versions_list(smart_proxy, href, options)
        repository_versions_api = ::Katello::Pulp3::Repository.new(nil, smart_proxy).repository_versions_api
        fetch_from_list { |page_opts| repository_versions_api.list(href, page_opts.merge(options)) }
      end

      def self.list(smart_proxy, options)
        repositories_api = ::Katello::Pulp3::Repository.new(nil, smart_proxy).repositories_api
        fetch_from_list do |page_opts|
          repositories_api.list(page_opts.merge(options))
        end
      end

      def self.fetch_from_list
        page_size = SETTINGS[:katello][:pulp][:bulk_load_size]
        page_opts = { "offset" => 0, limit: page_size }
        response = {}

        results = []

        loop do
          page_opts = page_opts.with_indifferent_access
          break unless (
            (response["count"] && (page_opts["offset"] < response["count"])) ||
            page_opts["offset"] == 0)
          response = yield page_opts
          response = response.as_json.with_indifferent_access
          results = results.concat(response[:results])
          page_opts[:offset] += page_size
        end

        results
      end

      def self.repository_versions(smart_proxy, options)
        current_pulp_repositories = ::Katello::Pulp3::Repository.list(smart_proxy, options)
        repo_hrefs = current_pulp_repositories.collect { |repo| repo[:_href] }.uniq

        version_hrefs = repo_hrefs.collect do |href|
          ::Katello::Pulp3::Repository.versions_list(smart_proxy, href, options).pluck(:_href)
        end

        version_hrefs.flatten.uniq
      end

      def self.orphan_repository_versions(smart_proxy)
        version_hrefs = repository_versions(smart_proxy, {})

        version_hrefs - ::Katello::Repository.where(version_href: version_hrefs).pluck(:version_href)
      end

      def self.delete_orphan_repository_versions(smart_proxy)
        orphans = orphan_repository_versions(smart_proxy)
        orphans.collect do |href|
          ::Katello::Pulp3::Repository.new(nil, smart_proxy).
            repository_versions_api.delete(href)
        end
      end

      def self.orphan_repository_versions_for_mirror(smart_proxy)
        current_pulp_repositories = ::Katello::Pulp3::Repository.list(smart_proxy, {})

        orphan_version_hrefs = current_pulp_repositories.collect do |pulp_repo|
          mirror_repo_versions = ::Katello::Pulp3::Repository.versions_list(
            smart_proxy, pulp_repo['_href'], ordering: :_created).pluck(:_href)

          mirror_repo_versions - [pulp_repo['_latest_version_href']]
        end

        orphan_version_hrefs.flatten
      end

      def self.delete_orphan_repository_versions_for_mirror(smart_proxy)
        orphans = orphan_repository_versions_for_mirror(smart_proxy)
        orphans.collect do |href|
          ::Katello::Pulp3::Repository.new(nil, smart_proxy).
            repository_versions_api.delete(href)
        end
      end

      def delete_mirror(href = mirror_repository_href)
        repositories_api.delete(href) if href
      end

      def delete(href = repository_reference.try(:repository_href))
        repository_reference.try(:destroy)
        repositories_api.delete(href) if href
      end

      def sync_mirror
        repository_sync_url_data = client_class::RepositorySyncURL.new(repository: mirror_repository_href, mirror: true)
        [remotes_api.sync(mirror_remote_href, repository_sync_url_data)]
      end

      def sync
        repository_sync_url_data = client_class::RepositorySyncURL.new(repository: repository_reference.repository_href, mirror: repo.root.mirror_on_sync)
        [remotes_api.sync(repo.remote_href, repository_sync_url_data)]
      end

      def mirror_version_href
        repository = fetch_repository
        repository._latest_version_href
      end

      def create_publication
        publication_data = publication_class.new(repository_version: repo.version_href)
        publications_api.create(publication_data)
      end

      def create_mirror_publication
        href = mirror_version_href
        if href
          publication_data = publication_class.new(repository_version: href)
          publications_api.create(publication_data)
        end
      end

      def relative_path
        repo.relative_path.sub(/^\//, '')
      end

      def refresh_mirror_distributions(options = {})
        path = relative_path
        dist_params = {}
        dist_params[:publication] = options[:publication] if options[:publication]
        dist_params[:repository_version] = mirror_version_href if options[:use_repository_version]
        dist_options = distribution_mirror_options(path, dist_params)
        if (distro = lookup_distributions(base_path: path).first)
          # update dist
          dist_options = dist_options.except(:name, :base_path)
          distributions_api.partial_update(distro._href, dist_options)
        else
          # create dist
          distribution_data = distribution_class.new(dist_options)
          distributions_api.create(distribution_data)
        end
      end

      def refresh_distributions
        path = relative_path
        dist_ref = distribution_reference(path)
        if dist_ref
          update_distribution(path)
        else
          create_distribution(path)
        end
      end

      def create_mirror_distribution(path)
        distribution_data = distribution_class.new(distribution_mirror_options(path))
        distributions_api.create(distribution_data)
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

      def mirror_repository_href
        fetch_repository.try(:_href)
      end

      def mirror_remote_href
        fetch_remote.try(:_href)
      end

      def create_mirror_version(options = {})
        href = mirror_repository_href
        repository_versions_api.create(href, options) if href
      end

      def create_version(options = {})
        repository_versions_api.create(repository_reference.repository_href, options)
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

      def common_mirror_remote_options
        remote_options = {
          name: backend_object_name,
          url: mirror_remote_feed_url
        }
        remote_options.merge!(ssl_mirror_remote_options)
      end

      def ssl_mirror_remote_options
        ueber_cert = ::Cert::Certs.ueber_cert(root.organization)
        {
          ssl_client_certificate: ueber_cert[:cert],
          ssl_client_key: ueber_cert[:key],
          ssl_ca_certificate: ::Cert::Certs.ca_cert,
          ssl_validation: true
        }
      end

      def mirror_remote_feed_url
        uri = ::SmartProxy.pulp_master.pulp3_uri!
        uri.path = partial_repo_path
        uri.to_s
      end

      def partial_repo_path
        fail NotImplementedError
      end

      def needs_importer_updates?
        false
      end

      def needs_distributor_updates?
        false
      end

      def lookup_version(href)
        repository_versions_api.read(href) if href
      rescue PulpcoreClient::ApiError => e
        Rails.logger.error "Exception when calling repository_versions_api->read: #{e}"
        nil
      end

      def lookup_publication(href)
        publications_api.read(href) if href
      rescue PulpcoreClient::ApiError => e
        Rails.logger.error "Exception when calling publications_api->read: #{e}"
        nil
      end

      def fetch_repository
        list(name: backend_object_name).first
      end

      def fetch_remote
        list_remotes(name: backend_object_name).first
      end

      def remove_content(content_units)
        data = PulpcoreClient::RepositoryVersionCreate.new(
          remove_content_units: content_units.map(&:pulp_id))
        repository_versions_api.create(repository_reference.repository_href, data)
      end

      def add_content(content_unit_href)
        content_unit_href = [content_unit_href] unless content_unit_href.is_a?(Array)
        data = PulpcoreClient::RepositoryVersionCreate.new(
            add_content_units: content_unit_href)
        repository_versions_api.create(repository_reference.repository_href, data)
      end

      def unit_keys(uploads)
        uploads.map do |upload|
          upload.except('id')
        end
      end
    end
  end
end
