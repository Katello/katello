require 'proxy_api'
require 'proxy_api/pulp'
require 'proxy_api/pulp_node'

module Katello
  module Concerns
    module SmartProxyExtensions
      extend ActiveSupport::Concern

      module Overrides
        def refresh
          errors = super
          update_puppet_path
          errors
        end
      end

      PULP3_FEATURE = "Pulpcore".freeze
      PULP_FEATURE = "Pulp".freeze
      PULP_NODE_FEATURE = "Pulp Node".freeze

      DOWNLOAD_INHERIT = 'inherit'.freeze
      DOWNLOAD_POLICIES = ::Runcible::Models::YumImporter::DOWNLOAD_POLICIES + [DOWNLOAD_INHERIT]

      included do
        include ForemanTasks::Concerns::ActionSubject
        include LazyAccessor

        prepend Overrides

        before_create :associate_organizations
        before_create :associate_default_locations
        before_create :associate_lifecycle_environments
        before_validation :set_default_download_policy

        lazy_accessor :pulp_repositories, :initializer => lambda { |_s| pulp_node.extensions.repository.retrieve_all }

        has_many :capsule_lifecycle_environments,
                 :class_name  => "Katello::CapsuleLifecycleEnvironment",
                 :foreign_key => :capsule_id,
                 :dependent   => :destroy,
                 :inverse_of => :capsule

        has_many :lifecycle_environments,
                 :class_name => "Katello::KTEnvironment",
                 :through    => :capsule_lifecycle_environments,
                 :source     => :lifecycle_environment

        has_many :content_facets, :class_name => "::Katello::Host::ContentFacet", :foreign_key => :content_source_id,
                                  :inverse_of => :content_source, :dependent => :nullify

        has_many :hostgroups, :class_name => "::Hostgroup", :foreign_key => :content_source_id,
                              :inverse_of => :content_source, :dependent => :nullify

        validates :download_policy, inclusion: {
          :in => DOWNLOAD_POLICIES,
          :message => _("must be one of the following: %s") % DOWNLOAD_POLICIES.join(', ')
        }
        scope :with_content, -> { with_features(PULP_FEATURE, PULP_NODE_FEATURE) }

        def self.with_repo(repo)
          joins(:capsule_lifecycle_environments).
          where("#{Katello::CapsuleLifecycleEnvironment.table_name}.lifecycle_environment_id" => repo.environment_id)
        end

        def self.pulp_master
          unscoped.with_features(PULP_FEATURE).first
        end

        def self.pulp_master!
          pulp_master || fail(_("Could not find a smart proxy with pulp feature."))
        end

        def self.default_capsule
          pulp_master
        end

        def self.default_capsule!
          pulp_master!
        end

        def self.with_environment(environment, include_default = false)
          features = [PULP_NODE_FEATURE]
          features << PULP_FEATURE if include_default

          unscoped.with_features(features).joins(:capsule_lifecycle_environments).
              where(katello_capsule_lifecycle_environments: { lifecycle_environment_id: environment.id })
        end

        def self.sync_needed?(environment)
          unscoped.with_environment(environment).any?
        end
      end

      def puppet_path
        self[:puppet_path] || update_puppet_path
      end

      def update_puppet_path
        if has_feature?(PULP_FEATURE)
          path = ProxyAPI::Pulp.new(:url => self.url).capsule_puppet_path['puppet_content_dir']
        elsif has_feature?(PULP_NODE_FEATURE)
          path = ProxyAPI::PulpNode.new(:url => self.url).capsule_puppet_path['puppet_content_dir']
        end
        self.update_attribute(:puppet_path, path || '') if persisted?
        path
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
          config.ssl_client_cert = ::Cert::Certs.ssl_client_cert
          config.ssl_client_key = ::Cert::Certs.ssl_client_key
          config.debugging = true
          config.logger = ::Foreman::Logging.logger('katello/pulp_rest')
        end
      end

      def backend_service_type(repository)
        if pulp3_support?(repository)
          Actions::Pulp3::Abstract::BACKEND_SERVICE_TYPE
        else
          Actions::Pulp::Abstract::BACKEND_SERVICE_TYPE
        end
      end

      def pulp3_enabled?
        self.has_feature? PULP3_FEATURE
      end

      def pulp3_support?(repository)
        pulp3_repository_type_support?(repository.content_type)
      end

      def pulp2_preferred_for_type?(repository_type)
        if SETTINGS[:katello][:use_pulp_2_for_content_type].nil? ||
            SETTINGS[:katello][:use_pulp_2_for_content_type][repository_type.to_sym].nil?
          return false
        else
          return SETTINGS[:katello][:use_pulp_2_for_content_type][repository_type.to_sym]
        end
      end

      def pulp3_repository_type_support?(repository_type, check_pulp2_preferred = true)
        repository_type_obj = repository_type.is_a?(String) ? Katello::RepositoryTypeManager.repository_types[repository_type] : repository_type
        fail "Cannot find repository type #{repository_type}, is it enabled?" unless repository_type_obj

        pulp3_supported = repository_type_obj.pulp3_plugin.present? &&
                          pulp3_enabled? &&
                          self.capabilities(PULP3_FEATURE).try(:include?, repository_type_obj.pulp3_plugin)

        check_pulp2_preferred ? pulp3_supported && !pulp2_preferred_for_type?(repository_type_obj.id) : pulp3_supported
      end

      def pulp3_content_support?(content_type)
        content_type_obj = content_type.is_a?(String) ? Katello::RepositoryTypeManager.find_content_type(content_type) : content_type
        fail "Cannot find content type #{content_type}." unless content_type_obj

        found_type = Katello::RepositoryTypeManager.repository_types.values.find { |repo_type| repo_type.content_types.include?(content_type_obj) }
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

      def pulp3_url(path = '/pulp/api/v3/')
        pulp_url = self.setting(PULP3_FEATURE, 'pulp_url')
        path.blank? ? pulp_url : "#{pulp_url.sub(%r|/$|, '')}/#{path.sub(%r|^/|, '')}"
      end

      def pulp_mirror?
        self.has_feature? PULP_NODE_FEATURE
      end

      def pulp_master?
        self.has_feature? PULP_FEATURE
      end

      def supported_pulp_types
        supported_map = {
          pulp2: { supported_types: [] },
          pulp3: { supported_types: [], overriden_to_pulp2: [] }
        }

        ::Katello::RepositoryTypeManager.repository_types.keys.each do |type|
          if pulp3_repository_type_support?(type, false)
            if pulp2_preferred_for_type?(type)
              supported_map[:pulp3][:overriden_to_pulp2] << type
            else
              supported_map[:pulp3][:supported_types] << type
            end
          else
            supported_map[:pulp2][:supported_types] << type
          end
        end

        supported_map
      end

      #deprecated methods
      alias_method :pulp_node, :pulp_api
      alias_method :default_capsule?, :pulp_master?

      def associate_organizations
        self.organizations = Organization.all if self.pulp_master?
      end

      def associate_default_locations
        return unless self.pulp_master?
        ['puppet_content', 'subscribed_hosts'].each do |type|
          default_location = ::Location.unscoped.find_by_title(
            ::Setting[:"default_location_#{type}"])
          if default_location.present? && !locations.include?(default_location)
            self.locations << default_location
          end
        end
      end

      def content_service(content_type)
        content_type = RepositoryTypeManager.find_content_type(content_type) if content_type.is_a?(String)
        pulp3_content_support?(content_type) ? content_type.pulp3_service_class : content_type.pulp2_service_class
      end

      def set_default_download_policy
        self.download_policy ||= ::Setting[:default_proxy_download_policy] || ::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND
      end

      def associate_lifecycle_environments
        self.lifecycle_environments = Katello::KTEnvironment.all if self.pulp_master?
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

      def sync_tasks
        ForemanTasks::Task.for_resource(self)
      end

      def active_sync_tasks
        sync_tasks.where(:result => 'pending')
      end

      def last_failed_sync_tasks
        sync_tasks.where('started_at > ?', last_sync_time).where.not(:result => 'pending')
      end

      def last_sync_time
        task = sync_tasks.where.not(:ended_at => nil).where(:result => 'success').order(:ended_at).last
        task.ended_at unless task.nil?
      end

      def environment_syncable?(env)
        last_sync_time.nil? || env.content_view_environments.where('updated_at > ?', last_sync_time).any?
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

      def smart_proxy_service
        @smart_proxy_service ||= Pulp::SmartProxyRepository.new(self)
      end
    end
  end
end

class ::SmartProxy::Jail < Safemode::Jail
  allow :hostname
end
