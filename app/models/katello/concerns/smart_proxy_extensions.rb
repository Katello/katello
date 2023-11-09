require 'proxy_api'
require 'proxy_api/pulp'
require 'proxy_api/pulp_node'
require 'proxy_api/container_gateway'

module Katello
  module Concerns
    # rubocop:disable Metrics/ModuleLength
    module SmartProxyExtensions
      extend ActiveSupport::Concern

      module Overrides
        def refresh
          errors = super
          errors
        end
      end

      PULP3_FEATURE = "Pulpcore".freeze
      PULP_FEATURE = "Pulp".freeze
      PULP_NODE_FEATURE = "Pulp Node".freeze
      CONTAINER_GATEWAY_FEATURE = "Container_Gateway".freeze

      DOWNLOAD_INHERIT = 'inherit'.freeze
      DOWNLOAD_STREAMED = 'streamed'.freeze
      DOWNLOAD_POLICIES = [::Katello::RootRepository::DOWNLOAD_ON_DEMAND, ::Katello::RootRepository::DOWNLOAD_IMMEDIATE, DOWNLOAD_INHERIT, DOWNLOAD_STREAMED].freeze

      included do
        include ForemanTasks::Concerns::ActionSubject
        include LazyAccessor

        prepend Overrides

        before_create :associate_organizations
        before_create :associate_default_locations
        before_create :associate_lifecycle_environments
        before_validation :set_default_download_policy

        lazy_accessor :pulp_repositories, :initializer => lambda { |_s| pulp_node.extensions.repository.retrieve_all }

        # A smart proxy's HTTP proxy is used for all related alternate content sources.
        belongs_to :http_proxy, :inverse_of => :smart_proxies, :class_name => '::HttpProxy'

        has_many :capsule_lifecycle_environments,
                 :class_name => "Katello::CapsuleLifecycleEnvironment",
                 :foreign_key => :capsule_id,
                 :dependent => :destroy,
                 :inverse_of => :capsule

        has_many :lifecycle_environments,
                 :class_name => "Katello::KTEnvironment",
                 :through => :capsule_lifecycle_environments,
                 :source => :lifecycle_environment

        has_many :content_facets, :class_name => "::Katello::Host::ContentFacet", :foreign_key => :content_source_id,
                 :inverse_of => :content_source, :dependent => :nullify

        has_many :smart_proxy_sync_histories, :class_name => "::Katello::SmartProxySyncHistory", :inverse_of => :smart_proxy, dependent: :delete_all

        has_many :hostgroup_content_facets, :class_name => "::Katello::Hostgroup::ContentFacet", :foreign_key => :content_source_id,
                 :inverse_of => :content_source, :dependent => :nullify
        has_many :hostgroups, :class_name => "::Hostgroup", :through => :hostgroup_content_facets
        has_many :smart_proxy_alternate_content_sources, :class_name => "::Katello::SmartProxyAlternateContentSource", :inverse_of => :smart_proxy, :dependent => :delete_all

        validates :download_policy, inclusion: {
          :in => DOWNLOAD_POLICIES,
          :message => _("must be one of the following: %s") % DOWNLOAD_POLICIES.join(', ')
        }
        scope :with_content, -> { with_features(PULP_FEATURE, PULP_NODE_FEATURE, PULP3_FEATURE) }

        def self.with_repo(repo)
          joins(:capsule_lifecycle_environments).
            where("#{Katello::CapsuleLifecycleEnvironment.table_name}.lifecycle_environment_id" => repo.environment_id)
        end

        def self.pulp_primary
          unscoped.with_features(PULP_FEATURE).first || non_mirror_pulp3
        end

        def self.non_mirror_pulp3
          found = unscoped.with_features(PULP3_FEATURE).order(:id).select { |proxy| !proxy.setting(PULP3_FEATURE, 'mirror') }
          Rails.logger.warn("Found multiple smart proxies with mirror set to false.  This is likely not intentional.") if found.count > 1
          found.first
        end

        def self.pulp_primary!
          pulp_primary || fail(_("Could not find a smart proxy with pulp feature."))
        end

        def self.default_capsule
          pulp_primary
        end

        def self.default_capsule!
          pulp_primary!
        end

        def self.with_environment(environment, include_default = false)
          (pulp2_proxies_with_environment(environment, include_default) + pulpcore_proxies_with_environment(environment)).try(:uniq)
        end

        def self.pulp2_proxies_with_environment(environment, include_default = false)
          features = [PULP_NODE_FEATURE]
          features << PULP_FEATURE if include_default

          unscoped.with_features(features).joins(:capsule_lifecycle_environments).
            where(katello_capsule_lifecycle_environments: { lifecycle_environment_id: environment.id })
        end

        def self.pulpcore_proxies_with_environment(environment)
          unscoped.where(id: unscoped.select { |p| p.pulp_mirror? }.pluck(:id)).joins(:capsule_lifecycle_environments).
            where(katello_capsule_lifecycle_environments: { lifecycle_environment_id: environment.id })
        end

        def self.sync_needed?(environment)
          Setting[:foreman_proxy_content_auto_sync] && unscoped.with_environment(environment).any?
        end
      end

      def alternate_content_sources
        SmartProxy.joins(:smart_proxy_alternate_content_sources).where('katello_smart_proxy_alternate_content_sources.smart_proxy_id' => self.id)
      end

      def update_content_counts!
        # {:content_view_versions=>{87=>{:repositories=>{1=>{:metadata=>{},:counts=>{:rpms=>98, :module_streams=>9898}}}}}
        new_content_counts = { content_view_versions: {} }
        smart_proxy_helper = ::Katello::SmartProxyHelper.new(self)
        repos = smart_proxy_helper.repositories_available_to_capsule

        repos&.each do |repo|
          repo_mirror_service = repo.backend_service(self).with_mirror_adapter
          repo_content_counts = repo_mirror_service.latest_content_counts
          translated_counts = {metadata: {}, counts: {}}
          translated_counts[:metadata] = {
            env_id: repo.environment_id,
            library_instance_id: repo.library_instance_or_self.id,
            product_id: repo.product_id,
            content_type: repo.content_type
          }
          repo_content_counts&.each do |name, count|
            count = count[:count]
            # Some content units in Pulp have the same model
            if name == 'rpm.package' && repo.content_counts['srpm'] > 0
              translated_counts[:counts]['srpm'] = repo_mirror_service.count_by_pulpcore_type(::Katello::Pulp3::Srpm)
              translated_counts[:counts]['rpm'] = count - translated_counts[:counts]['srpm']
            elsif name == 'container.manifest' && repo.content_counts['docker_manifest_list'] > 0
              translated_counts[:counts]['docker_manifest_list'] = repo_mirror_service.count_by_pulpcore_type(::Katello::Pulp3::DockerManifestList)
              translated_counts[:counts]['docker_manifest'] = count - translated_counts[:counts]['docker_manifest_list']
            else
              translated_counts[:counts][::Katello::Pulp3::PulpContentUnit.katello_name_from_pulpcore_name(name, repo)] = count
            end
          end
          new_content_counts[:content_view_versions][repo.content_view_version_id] ||= { repositories: {}}
          # Store counts on capsule of archived repos which are reused across environment copies
          # of the archived repo corresponding to each environment CV version is promoted to.
          new_content_counts[:content_view_versions][repo.content_view_version_id][:repositories][repo.id] = translated_counts
        end
        update(content_counts: new_content_counts)
      end

      def sync_container_gateway
        if has_feature?(::SmartProxy::CONTAINER_GATEWAY_FEATURE)
          update_container_repo_list
          users = container_gateway_users
          update_user_container_repo_mapping(users) if users.any?
        end
      end

      def update_container_repo_list
        # [{ repository: "repoA", auth_required: false }]
        repo_list = []
        ::Katello::SmartProxyHelper.new(self).combined_repos_available_to_capsule.each do |repo|
          if repo.docker? && !repo.container_repository_name.nil?
            repo_list << { repository: repo.container_repository_name,
                           auth_required: !unauthenticated_container_repositories.include?(repo.id) }
          end
        end
        ::ProxyAPI::ContainerGateway.new(url: self.url).repository_list({ repositories: repo_list })
      end

      def update_user_container_repo_mapping(users)
        # Example user-repo mapping:
        # { users:
        #   [
        #     'user a' => [{ repository: 'repo 1', auth_required: true }]
        #   ]
        # }

        user_repo_map = { users: [] }
        users.each do |user|
          inner_repo_list = []
          repositories = ::Katello::Repository.readable_docker_catalog_as(user)
          repositories.each do |repo|
            next if repo.container_repository_name.nil?
            inner_repo_list << { repository: repo.container_repository_name,
                                 auth_required: !unauthenticated_container_repositories.include?(repo.id) }
          end
          user_repo_map[:users] << { user.login => inner_repo_list }
        end
        ProxyAPI::ContainerGateway.new(url: self.url).user_repository_mapping(user_repo_map)
      end

      def unauthenticated_container_repositories
        ::Katello::Repository.joins(:environment).where("#{::Katello::KTEnvironment.table_name}.registry_unauthenticated_pull" => true).select(:id).pluck(:id)
      end

      def container_gateway_users
        usernames = ProxyAPI::ContainerGateway.new(url: self.url).users
        ::User.where(login: usernames['users'])
      end

      def pulp_url
        uri = URI.parse(url)
        "#{uri.scheme}://#{uri.host}/pulp/api/v2/"
      end

      def pulp_api
        @pulp_api ||= Katello::Pulp::Server.config(pulp_url, User.remote_user)
      end

      def pulp3_configuration(config_class)
        config_class.new do |config|
          uri = pulp3_uri!
          config.host = uri.host
          config.scheme = uri.scheme
          pulp3_ssl_configuration(config)
          config.debugging = ::Foreman::Logging.logger('katello/pulp_rest').debug?
          config.timeout = SETTINGS[:katello][:rest_client_timeout]
          config.logger = ::Foreman::Logging.logger('katello/pulp_rest')
          config.username = self.setting(PULP3_FEATURE, 'username')
          config.password = self.setting(PULP3_FEATURE, 'password')
        end
      end

      def pulp3_ssl_configuration(config, connection_adapter = Faraday.default_adapter)
        if connection_adapter == :excon
          config.ssl_client_cert = ::Cert::Certs.ssl_client_cert_filename
          config.ssl_client_key = ::Cert::Certs.ssl_client_key_filename
        elsif connection_adapter == :net_http
          config.ssl_client_cert = ::Cert::Certs.ssl_client_cert
          config.ssl_client_key = ::Cert::Certs.ssl_client_key
        else
          fail "Unexpected connection_adapter #{Faraday.default_adapter}!  Cannot continue, this is likely a bug."
        end
      end

      def pulp_disk_usage
        if pulp3_enabled?
          storage = ping_pulp3['storage']
          if storage.nil?
            [
              {
                description: 'Pulp Storage (no detailed information available)',
                total: -1,
                used: -1,
                free: -1,
                percentage: -1,
                label: 'cloud-storage'
              }.with_indifferent_access
            ]
          else
            [
              {
                description: 'Pulp Storage (/var/lib/pulp by default)',
                total: storage['total'],
                used: storage['used'],
                free: storage['free'],
                percentage: (storage['used'] / storage['total'].to_f * 100).to_i,
                label: 'pulp_dir'
              }.with_indifferent_access
            ]
          end
        end
      end

      def pulp3_enabled?
        self.has_feature? PULP3_FEATURE
      end

      def pulp3_support?(repository)
        repository ? pulp3_repository_type_support?(repository.try(:content_type)) : false
      end

      def missing_pulp3_capabilities?
        pulp3_enabled? && self.capabilities(PULP3_FEATURE).empty?
      end

      def fix_pulp3_capabilities(type)
        if type.is_a?(String) || type.is_a?(Symbol)
          repository_type_obj = Katello::RepositoryTypeManager.defined_repository_types[type]
        else
          repository_type_obj = type
        end

        if missing_pulp3_capabilities? && repository_type_obj.pulp3_plugin
          self.refresh
          if self.capabilities(::SmartProxy::PULP3_FEATURE).empty?
            fail Katello::Errors::PulpcoreMissingCapabilities
          end
        end
      end

      def pulp3_repository_type_support?(repository_type)
        repository_type_obj = repository_type.is_a?(String) ? Katello::RepositoryTypeManager.find(repository_type) : repository_type
        fail "Cannot find repository type #{repository_type}, is it enabled?" unless repository_type_obj

        repository_type_obj.pulp3_plugin.present? &&
          pulp3_enabled? &&
          (self.capabilities(PULP3_FEATURE).try(:include?, repository_type_obj.pulp3_plugin) ||
            self.capabilities(PULP3_FEATURE).try(:include?, 'pulp_' + repository_type_obj.pulp3_plugin))
      end

      def pulp3_content_support?(content_type)
        content_type_obj = content_type.is_a?(String) ? Katello::RepositoryTypeManager.find_content_type(content_type) : content_type
        content_type_string = content_type_obj&.label || content_type
        fail "Content type #{content_type_string} does not belong to an enabled repo type." unless content_type_obj

        found_type = Katello::RepositoryTypeManager.enabled_repository_types.values.find { |repo_type| repo_type.content_types.include?(content_type_obj) }
        fail "Cannot find repository type for content_type #{content_type}, is it enabled?" unless found_type
        pulp3_repository_type_support?(found_type)
      end

      def pulp3_uri!
        url = self.setting(PULP3_FEATURE, 'pulp_url')
        fail "Cannot determine pulp3 url, check smart proxy configuration" unless url
        URI.parse(url)
      end

      def pulp3_host!
        pulp3_uri!.host
      end

      def pulp3_url(path = '/pulp/api/v3')
        pulp_url = self.setting(PULP3_FEATURE, 'pulp_url')
        path.blank? ? pulp_url : "#{pulp_url.sub(%r|/$|, '')}/#{path.sub(%r|^/|, '')}"
      end

      def pulp_mirror?
        self.has_feature?(PULP_NODE_FEATURE) || self.setting(SmartProxy::PULP3_FEATURE, 'mirror')
      end

      def pulp_primary?
        self.has_feature?(PULP_FEATURE) || self.setting(SmartProxy::PULP3_FEATURE, 'mirror') == false
      end

      def supported_pulp_types
        supported_types = []

        ::Katello::RepositoryTypeManager.enabled_repository_types.keys.each do |type|
          if pulp3_repository_type_support?(type)
            supported_types << type
          end
        end

        supported_types
      end

      #deprecated methods
      alias_method :pulp_node, :pulp_api
      alias_method :default_capsule?, :pulp_primary?

      def associate_organizations
        self.organizations = Organization.all if self.pulp_primary?
      end

      def associate_default_locations
        return unless self.pulp_primary?
        default_location = ::Location.unscoped.find_by_title(
          ::Setting[:default_location_subscribed_hosts])
        if default_location.present? && !locations.include?(default_location)
          self.locations << default_location
        end
      end

      def content_service(content_type)
        if content_type.is_a?(String)
          content_type_obj = RepositoryTypeManager.find_content_type(content_type)
        else
          content_type_obj = content_type
        end
        content_type_string = content_type_obj&.label || content_type
        unless content_type_obj
          fail _("Content type %{content_type_string} does not belong to an enabled repo type.") %
                 { content_type_string: content_type_string }
        end
        content_type_obj.pulp3_service_class
      end

      def set_default_download_policy
        self.download_policy ||= ::Setting[:default_proxy_download_policy] || ::Katello::RootRepository::DOWNLOAD_ON_DEMAND
      end

      def associate_lifecycle_environments
        self.lifecycle_environments = Katello::KTEnvironment.all if self.pulp_primary?
      end

      def add_lifecycle_environment(environment)
        self.lifecycle_environments << environment
      end

      def remove_lifecycle_environment(environment)
        self.lifecycle_environments.find(environment.id)
        unless self.lifecycle_environments.destroy(environment)
          fail _("Could not remove the lifecycle environment from the smart proxy")
        end
      rescue ActiveRecord::RecordNotFound
        raise _("Lifecycle environment was not attached to the smart proxy; therefore, no changes were made.")
      end

      def available_lifecycle_environments(organization_id = nil)
        scope = Katello::KTEnvironment.not_in_capsule(self)
        scope = scope.where(organization_id: organization_id) if organization_id
        scope
      end

      def last_complete_sync_task
        ForemanTasks::Task.for_resource(self).where(:label => 'Actions::Katello::CapsuleContent::Sync').order(started_at: :desc).detect do |task|
          task.input.with_indifferent_access[:options][:environment_id].nil? &&
          task.input.with_indifferent_access[:options][:content_view_id].nil? &&
          task.input.with_indifferent_access[:options][:repository_id].nil?
        end
      end

      def sync_tasks
        ForemanTasks::Task.for_resource(self).where(:label => 'Actions::Katello::CapsuleContent::Sync')
      end

      def active_sync_tasks
        sync_tasks.where(:result => 'pending')
      end

      def last_failed_sync_tasks
        sync_tasks.where('started_at > ?', last_sync_time).where.not(:result => 'pending')
      end

      def last_sync_audit
        Audited::Audit.where(:auditable_id => self, :auditable_type => SmartProxy.name, action: "sync capsule").order(:created_at).last
      end

      def last_sync_task
        sync_tasks.where.not(:ended_at => nil).where(:result => 'success').order(:ended_at).last
      end

      def last_sync_time
        last_sync_task&.ended_at || last_sync_audit&.created_at&.to_s
      end

      def environment_syncable?(env)
        last_sync_time.nil? || env.content_view_environments.where('updated_at > ?', last_sync_time).any?
      end

      def last_env_sync_task(env)
        last_env_sync_task = sync_tasks.order(ended_at: :desc).detect { |task| task.input.with_indifferent_access[:options][:environment_id] == env.id || task.input.with_indifferent_access[:options][:environment_ids]&.include?(env.id) }

        # env_ids_task_exists checks if any full syncs have run since we started tracking env_ids at time of sync.
        # If yes, return last_env_sync_task which checks for env_id specific sync + full syncs which contain env as part of env_ids
        env_ids_task_exists = sync_tasks.order(ended_at: :desc).any? { |task| task.input.with_indifferent_access[:options][:environment_ids] }
        return last_env_sync_task if env_ids_task_exists

        if (last_complete_sync_task&.ended_at && last_env_sync_task&.ended_at)
          return last_complete_sync_task.ended_at > last_env_sync_task.ended_at ? last_complete_sync_task : last_env_sync_task
        elsif last_env_sync_task
          return last_env_sync_task
        elsif last_complete_sync_task
          return last_complete_sync_task
        end
      end

      def cancel_sync
        active_sync_tasks.map(&:cancel)
      end

      def ping_pulp
        ::Katello::Ping.pulp_without_auth(self.pulp_url)
      rescue Errno::EHOSTUNREACH, Errno::ECONNREFUSED, RestClient::Exception => error
        raise ::Katello::Errors::CapsuleCannotBeReached, _("%s is unreachable. %s" % [self.name, error])
      end

      def ping_pulp3
        ::Katello::Ping.pulp3_without_auth(self.pulp3_url)
      rescue Errno::EHOSTUNREACH, Errno::ECONNREFUSED, RestClient::Exception => error
        raise ::Katello::Errors::CapsuleCannotBeReached, _("%s is unreachable. %s" % [self.name, error])
      end

      def verify_ueber_certs
        self.organizations.each do |org|
          Cert::Certs.verify_ueber_cert(org)
        end
      end

      def repos_in_env_cv(environment = nil, content_view = nil)
        repos = Katello::Repository
        repos = repos.in_environment(environment) if environment
        repos = repos.in_content_views([content_view]) if content_view
        repos.respond_to?(:to_a) ? repos : repos.none
      end

      def repos_in_sync_history
        smart_proxy_sync_histories.map { |sync_history| sync_history.repository }
      end

      def current_repositories_data(environment = nil, content_view = nil)
        return repos_in_sync_history unless (environment || content_view)
        repos_in_sync_history & repos_in_env_cv(environment, content_view)
      end

      def repos_pending_sync(environment = nil, content_view = nil)
        repos_in_env_cv(environment, content_view) - repos_in_sync_history
      end

      def rhsm_url
        # Since Foreman 3.1 this setting is set
        if (rhsm_url = setting(SmartProxy::PULP3_FEATURE, 'rhsm_url'))
          URI(rhsm_url)
          # Compatibility fall back
        elsif pulp_primary?
          URI("https://#{URI.parse(url).host}/rhsm")
        elsif pulp_mirror?
          URI("https://#{URI.parse(url).host}:8443/rhsm")
        end
      end

      def pulp_content_url
        URI(setting(SmartProxy::PULP3_FEATURE, 'content_app_url'))
      end

      def audit_capsule_sync
        write_audit(action: "sync capsule", comment: _('Successfully synced capsule.'), audited_changes: {})
      end

      class ::SmartProxy::Jail < ::Safemode::Jail
        allow :rhsm_url, :pulp_content_url
      end
    end
  end
end
