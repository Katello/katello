module Katello
  module Pulp3
    class RepositoryMirror
      attr_accessor :repo_service
      delegate :repo, to: :repo_service
      delegate :smart_proxy, to: :repo_service

      delegate :api, to: :repo_service

      def initialize(repository_service)
        @repo_service = repository_service
      end

      def backend_object_name
        #Create repos in pulp3 instance with the name as this repo's pulp_id
        repo.pulp_id
      end

      def refresh_entities
        href = remote_href
        if href
          [api.remotes_api.partial_update(href, remote_options)]
        else
          create_remote
          []
        end
      end

      def needs_updates?
        remote = fetch_remote
        return true if remote.blank?
        options = compute_remote_options
        options.keys.any? { |key| remote.send(key) != options[key] }
      end

      def remote_href
        fetch_remote.try(:pulp_href)
      end

      def create_entities
        create
        create_remote unless fetch_remote
      end

      def create
        api.repositories_api.create(name: backend_object_name)
      end

      def update
        api.repositories_api.update(repository_href, name: backend_object_name)
      end

      def delete(href = repository_href)
        api.repositories_api.delete(href) if href
      end

      def repository_href
        fetch_repository.try(:pulp_href)
      end

      def fetch_repository
        repo_service.api.list_all(name: backend_object_name).first
      end

      def version_href
        fetch_repository.latest_version_href
      end

      def create_version(options = {})
        api.repository_versions_api.create(repository_href, options)
      end

      def distribution_options(path, options = {})
        ret = {
          base_path: path,
          name: "#{backend_object_name}"
        }
        ret[:publication] = options[:publication] if options.key? :publication
        ret[:repository_version] = options[:repository_version] if options.key? :repository_version
        ret
      end

      def remote_options
        base_options = common_remote_options.merge(url: remote_feed_url)
        type_options = api.try(:mirror_remote_options) || {}
        type_options.merge(base_options)
      end

      def create_remote
        remote_file_data = @repo_service.api.class.remote_class.new(remote_options)
        api.remotes_api.create(remote_file_data)
      end

      def compute_remote_options
        computed_options = remote_options
        [:ssl_client_certificate, :ssl_client_key, :ssl_ca_certificate].each do |key|
          computed_options[key] = Digest::SHA256.hexdigest(computed_options[key].chomp)
        end
        computed_options
      end

      def fetch_remote
        api.remotes_list(name: backend_object_name).first
      end

      def sync
        api_module = api.class.client_module
        repository_sync_url_data = api_module::RepositorySyncURL.new(repository: repository_href, mirror: true)
        [api.remotes_api.sync(remote_href, repository_sync_url_data)]
      end

      def common_remote_options
        remote_options = {
          name: backend_object_name
        }
        remote_options.merge!(ssl_remote_options)
      end

      def ssl_remote_options
        ueber_cert = ::Cert::Certs.ueber_cert(repo.root.organization)
        {
          ssl_client_certificate: ueber_cert[:cert],
          ssl_client_key: ueber_cert[:key],
          ssl_ca_certificate: ::Cert::Certs.ca_cert,
          ssl_validation: true
        }
      end

      def remote_feed_url
        uri = ::SmartProxy.pulp_master.pulp3_uri!
        uri.path = repo_service.partial_repo_path
        uri.to_s
      end

      def create_publication
        if (href = version_href)
          publication_data = api.class.publication_class.new(repository_version: href)
          api.publications_api.create(publication_data)
        end
      end

      def refresh_distributions(options = {})
        path = repo_service.relative_path
        dist_params = {}
        dist_params[:publication] = options[:publication] if options[:publication]
        dist_params[:repository_version] = version_href if options[:use_repository_version]
        dist_options = distribution_options(path, dist_params)
        if (distro = repo_service.lookup_distributions(base_path: path).first)
          # update dist
          dist_options = dist_options.except(:name, :base_path)
          api.distributions_api.partial_update(distro.pulp_href, dist_options)
        else
          # create dist
          distribution_data = api.class.distribution_class.new(dist_options)
          api.distributions_api.create(distribution_data)
        end
      end

      def create_distribution(path)
        distribution_data = api.class.distribution_class.new(distribution_options(path))
        repo_service.distributions_api.create(distribution_data)
      end

      def orphan_repository_versions
        current_pulp_repositories = self.list

        orphan_version_hrefs = current_pulp_repositories.collect do |pulp_repo|
          mirror_repo_versions = api.versions_list(pulp_repo['pulp_href'], ordering: :_created).pluck(:pulp_href)

          mirror_repo_versions - [pulp_repo['latest_version_href']]
        end

        orphan_version_hrefs.flatten
      end

      def delete_orphan_repository_versions
        orphan_repository_versions.collect do |href|
          repo_service.api.repositories_api.delete(href)
        end
      end
    end
  end
end
