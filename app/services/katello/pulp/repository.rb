module Katello
  module Pulp
    class Repository < ::Actions::Pulp::Abstract
      attr_accessor :repo, :input, :pulp_api
      attr_accessor :smart_proxy
      delegate :root, to: :repo

      def initialize(repo, smart_proxy)
        @repo = repo
        @smart_proxy = smart_proxy
      end

      def backend_data
        @backend_data ||= smart_proxy.pulp_api.extensions.repository.retrieve_with_details(repo.pulp_id) if repo.pulp_id
      rescue RestClient::ResourceNotFound
        nil
      end

      def self.instance_for_type(repo, smart_proxy)
        Katello::RepositoryTypeManager.repository_types[repo.root.content_type].service_class.new(repo, smart_proxy)
      end

      def partial_repo_path
        fail NotImplementedError
      end

      def importer_class
        fail NotImplementedError
      end

      def master_importer_configuration
        fail NotImplementedError
      end

      def mirror_importer_configuration
        fail NotImplementedError
      end

      def generate_mirror_importer
        fail NotImplementedError
      end

      def generate_master_importer
        fail NotImplementedError
      end

      def generate_distributors
        fail NotImplementedError
      end

      def sync(overrides = {})
        sync_options = {}
        sync_options[:max_speed] = SETTINGS.dig(:katello, :pulp, :sync_KBlimit)
        sync_options[:num_threads] = SETTINGS.dig(:katello, :pulp, :sync_threads)
        sync_options[:feed] = overrides[:feed] if overrides[:feed]
        sync_options[:validate] = !SETTINGS.dig(:katello, :pulp, :skip_checksum_validation)
        sync_options.merge!(overrides[:options]) if overrides[:options]
        [smart_proxy.pulp_api.resources.repository.sync(@repo.pulp_id, override_config: sync_options.compact!)]
      end

      def create
        smart_proxy.pulp_api.extensions.repository.create_with_importer_and_distributors(repo.pulp_id, generate_importer,
                                                                              generate_distributors, display_name: root.name)
      end

      def external_url(force_https = false)
        uri = URI.parse(::SmartProxy.pulp_master.pulp_url)
        uri.scheme = (root.unprotected && !force_https) ? 'http' : 'https'
        uri.path = partial_repo_path
        uri.to_s
      end

      def generate_importer
        if smart_proxy.pulp_mirror?
          generate_mirror_importer
        elsif repo.in_default_view?
          generate_master_importer
        else #content view repositories don't need any importer configuration
          importer_class.new
        end
      end

      def master_importer_connection_options
        options = {
          proxy_host: self.proxy_host_importer_value,
          basic_auth_username: root.upstream_username,
          basic_auth_password: root.upstream_password,
          ssl_validation: root.verify_ssl_on_sync?
        }
        options.merge(master_importer_ssl_options)
      end

      def master_importer_ssl_options
        if root.redhat? && Katello::Resources::CDN::CdnResource.redhat_cdn?(root.url)
          {
            ssl_client_cert: root.product.certificate,
            ssl_client_key: root.product.key,
            ssl_ca_cert: Katello::Repository.feed_ca_cert(root.url)
          }
        elsif root.custom?
          {
            ssl_client_cert: root.ssl_client_cert&.content,
            ssl_client_key: root.ssl_client_key&.content,
            ssl_ca_cert: root.ssl_ca_cert&.content
          }
        else
          {}
        end
      end

      def mirror_importer_connection_options
        ueber_cert = ::Cert::Certs.ueber_cert(root.organization)
        {
          ssl_client_cert: ueber_cert[:cert],
          ssl_client_key: ueber_cert[:key],
          ssl_ca_cert: ::Cert::Certs.ca_cert
        }
      end

      def proxy_host_importer_value
        root.ignore_global_proxy ? "" : nil
      end
    end
  end
end
