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

      def backend_data(force = false)
        return smart_proxy.pulp_api.extensions.repository.retrieve_with_details(repo.pulp_id) if (repo.pulp_id && force)
        @backend_data ||= smart_proxy.pulp_api.extensions.repository.retrieve_with_details(repo.pulp_id) if repo.pulp_id
      rescue RestClient::ResourceNotFound
        nil
      end

      def self.instance_for_type(repo, smart_proxy)
        Katello::RepositoryTypeManager.repository_types[repo.root.content_type].service_class.new(repo, smart_proxy)
      end

      def unit_type_id(_uploads = [])
        @repo.unit_type_id
      end

      def unit_keys(uploads)
        uploads.map do |upload|
          upload.except('id', 'name')
        end
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

      def regenerate_applicability
        fail NotImplementedError
      end

      def copy_contents(_destination_repo, _filters)
        fail NotImplementedError
      end

      def content_service
        Katello::Pulp::Content
      end

      def should_purge_empty_contents?
        false
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

      def refresh
        tasks = update_or_associate_importer
        tasks += update_or_associate_distributors
        tasks += remove_unnecessary_distributors
        tasks
      end

      def update_or_associate_importer
        existing_importers = backend_data["importers"]
        importer = generate_importer
        found = existing_importers.find { |i| i['importer_type_id'] == importer.id }

        tasks = []
        if found
          ssl_ca_cert = importer.config.delete('ssl_ca_cert')
          ssl_client_cert = importer.config.delete('ssl_client_cert')
          ssl_client_key = importer.config.delete('ssl_client_key')
          importer.config['basic_auth_username'] = nil if importer.config['basic_auth_username'].blank?
          importer.config['basic_auth_password'] = nil if importer.config['basic_auth_password'].blank?
          # Update ssl options by themselves workaround for https://pulp.plan.io/issues/2727
          tasks << smart_proxy.pulp_api.resources.repository.update_importer(repo.pulp_id, found['id'], :ssl_client_cert => ssl_client_cert,
                                                    :ssl_client_key => ssl_client_key, :ssl_ca_cert => ssl_ca_cert)
          tasks << smart_proxy.pulp_api.resources.repository.update_importer(repo.pulp_id, found['id'], importer.config)
        else
          tasks << smart_proxy.pulp_api.resources.repository.associate_importer(repo.pulp_id, repo.importers.first['importer_type_id'], importer.config)
        end
        tasks
      end

      def update_or_associate_distributors
        tasks = []
        existing_distributors = backend_data["distributors"]
        generate_distributors.each do |distributor|
          found = existing_distributors.find { |i| i['distributor_type_id'] == distributor.type_id }
          if found
            tasks << smart_proxy.pulp_api.resources.repository.update_distributor(repo.pulp_id, found['id'], distributor.config)
          else
            smart_proxy.pulp_api.resources.repository.
                associate_distributor(repo.pulp_id, distributor.type_id, distributor.config, :distributor_id => distributor.id,
                                      :auto_publish => distributor.auto_publish)
          end
        end
        tasks
      end

      def remove_unnecessary_distributors
        tasks = []
        existing_distributors = backend_data["distributors"]
        generated_distributors = generate_distributors
        existing_distributors.each do |distributor|
          found = generated_distributors.find { |dist| dist.type_id == distributor['distributor_type_id'] }
          tasks << smart_proxy.pulp_api.resources.repository.delete_distributor(repo.pulp_id, distributor['id']) unless found
        end
        tasks
      end

      def copy_units(destination_repo, units, options = {})
        content_type = units.first.class::CONTENT_TYPE
        unit_ids = units.pluck(:pulp_id)
        override_config = {}
        override_config[:recursive] = true if options[:recursive]
        override_config[:resolve_dependencies] = true if options[:resolve_dependencies]

        smart_proxy.pulp_api.extensions.send(content_type).copy(repo.pulp_id, destination_repo.pulp_id, ids: unit_ids, override_config: override_config)
      end
    end
  end
end
