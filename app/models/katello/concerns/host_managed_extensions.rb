module Katello
  module Concerns
    module HostManagedExtensions
      extend ActiveSupport::Concern
      include Katello::KatelloUrlsHelper
      include ForemanTasks::Concerns::ActionSubject

      module Overrides
        def validate_media?
          (content_source_id.blank? || (content_facet && content_facet.kickstart_repository.blank?)) && super
        end

        def inherited_attributes
          inherited_attrs = super
          inherited_attrs.delete('medium_id') if content_facet && !content_facet.kickstart_repository.blank?
          inherited_attrs
        end

        def smart_proxy_ids
          ids = super
          ids << content_source_id
          ids.uniq.compact
        end

        def update_os_from_facts
          super

          # If facts causes the OS to change, our kickstart repo might not be
          # valid anymore. Let's reset it, either to nil or a valid one
          ks_repo = content_facet&.kickstart_repository
          valid_repos = operatingsystem.respond_to?(:kickstart_repos) ? (operatingsystem.kickstart_repos(self)&.pluck(:id) || []) : []

          if ks_repo && valid_repos.exclude?(ks_repo.id)
            content_facet.kickstart_repository_id = valid_repos.first
          end
        end

        def remote_execution_proxies(provider, *_rest)
          proxies = super
          if (name = subscription_facet&.registered_through)
            registered_through = SmartProxy.with_features(provider)
                                           .authorized
                                           .where(name: name)
          end
          proxies[:registered_through] = registered_through || []
          proxies
        end
      end

      included do
        prepend ::ForemanRemoteExecution::HostExtensions if ::Katello.with_remote_execution?
        prepend Overrides

        delegate :content_source_id, :single_content_view, :single_lifecycle_environment, :default_environment?, :single_content_view_environment?, :multi_content_view_environment?, :kickstart_repository_id, :bound_repositories, to: :content_facet, allow_nil: true

        has_many :content_view_environment_content_facets, through: :content_facet, class_name: 'Katello::ContentViewEnvironmentContentFacet'
        has_many :content_view_environments, through: :content_view_environment_content_facets
        has_many :content_views, through: :content_view_environments
        has_many :lifecycle_environments, through: :content_view_environments
        has_many :dispatch_histories, :class_name => "::Katello::Agent::DispatchHistory", :foreign_key => :host_id, :dependent => :delete_all

        has_many :host_installed_packages, :class_name => "::Katello::HostInstalledPackage", :foreign_key => :host_id, :dependent => :delete_all
        has_many :installed_packages, :class_name => "::Katello::InstalledPackage", :through => :host_installed_packages

        has_many :host_available_module_streams, :class_name => "::Katello::HostAvailableModuleStream", :foreign_key => :host_id, :dependent => :delete_all
        has_many :available_module_streams, :class_name => "::Katello::AvailableModuleStream", :through => :host_available_module_streams

        has_many :host_installed_debs, :class_name => "::Katello::HostInstalledDeb", :foreign_key => :host_id, :dependent => :delete_all
        has_many :installed_debs, :class_name => "::Katello::InstalledDeb", :through => :host_installed_debs
        has_many :host_traces, :class_name => "::Katello::HostTracer", :foreign_key => :host_id, :dependent => :destroy

        has_many :host_collection_hosts, :class_name => "::Katello::HostCollectionHosts", :foreign_key => :host_id, :dependent => :destroy
        has_many :host_collections, :class_name => "::Katello::HostCollection", :through => :host_collection_hosts

        has_many :hypervisor_pools, :class_name => '::Katello::Pool', :foreign_key => :hypervisor_id, :dependent => :nullify

        before_validation :correct_kickstart_repository
        before_update :check_host_registration, :if => proc { organization_id_changed? }

        after_validation :queue_reset_content_host_status
        register_rebuild(:queue_reset_content_host_status, N_("Content_Host_Status"))

        after_validation :queue_refresh_content_host_status
        register_rebuild(:queue_refresh_content_host_status, N_("Refresh_Content_Host_Status"))

        scope :with_pools_expiring_in_days, ->(days) { joins(:pools).merge(Katello::Pool.expiring_in_days(days)).distinct }

        scoped_search :relation => :host_collections, :on => :id, :complete_value => false, :rename => :host_collection_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
        scoped_search :relation => :host_collections, :on => :name, :complete_value => true, :rename => :host_collection
        scoped_search :relation => :installed_packages, :on => :nvra, :complete_value => true, :rename => :installed_package, :only_explicit => true
        scoped_search :relation => :installed_packages, :on => :name, :complete_value => true, :rename => :installed_package_name, :only_explicit => true
        scoped_search :relation => :installed_debs, :on => :name, :rename => :installed_deb, :only_explicit => true, :ext_method => :find_by_installed_debs, operators: ['=']
        scoped_search :relation => :installed_debs, :on => :name, :complete_value => true, :rename => :installed_package_name, :only_explicit => true
        scoped_search :relation => :available_module_streams, :on => :name, :complete_value => true, :rename => :available_module_stream_name, :only_explicit => true
        scoped_search :relation => :available_module_streams, :on => :stream, :complete_value => true, :rename => :available_module_stream_stream, :only_explicit => true
        scoped_search :relation => :host_traces, :on => :application, :complete_value => true, :rename => :trace_app, :only_explicit => true
        scoped_search :relation => :host_traces, :on => :app_type, :complete_value => true, :rename => :trace_app_type, :only_explicit => true
        scoped_search :relation => :host_traces, :on => :helper, :complete_value => true, :rename => :trace_helper, :only_explicit => true
        scoped_search :relation => :lifecycle_environments, :on => :name, :complete_value => true, :rename => :lifecycle_environment, :only_explicit => true
        scoped_search :relation => :content_views, :on => :name, :complete_value => true, :rename => :content_view, :only_explicit => true
        scoped_search :relation => :lifecycle_environments, :on => :id, :complete_value => true, :rename => :lifecycle_environment_id, :only_explicit => true
        scoped_search :relation => :content_views, :on => :id, :complete_value => true, :rename => :content_view_id, :only_explicit => true

        scoped_search relation: :pools, on: :pools_expiring_in_days, ext_method: :find_with_expiring_pools, only_explicit: true

        def self.find_with_expiring_pools(_key, _operator, days_from_now)
          host_ids = with_pools_expiring_in_days(days_from_now).ids
          if host_ids.any?
            { :conditions => "hosts.id IN (#{host_ids.join(', ')})" }
          else
            { :conditions => "1=0" }
          end
        end

        apipie :class do
          property :content_source, 'SmartProxy', desc: 'Returns Smart Proxy object as the content source for the host'
          property :subscription_manager_configuration_url, String, desc: 'Returns URL for subscription manager configuration'
          property :rhsm_organization_label, String, desc: 'Returns label of the Red Hat Subscription Manager organization'
          property :host_collections, array_of: 'HostCollection', desc: 'Returns list of the host collections the host belongs to'
          property :pools, array_of: 'Pool', desc: 'Returns subscription pool objects associated with the host'
          property :hypervisor_host, 'Host', desc: 'Returns hypervisor host object of this host'
          property :lifecycle_environments, 'KTEnvironment', desc: 'Returns lifecycle environments associated with the host'
          property :content_views, 'ContentView', desc: 'Returns content views associated with the host'
          property :installed_packages, array_of: 'InstalledPackage', desc: 'Returns a list of packages installed on the host'
        end
      end

      def check_host_registration
        if subscription_facet
          fail ::Katello::Errors::HostRegisteredException
        end
      end

      def refresh_content_host_status
        if content_facet&.present?
          self.host_statuses.where(type: ::Katello::HostStatusManager::STATUSES.map(&:name)).each do |status|
            status.refresh!
          end
        end
        refresh_global_status
      end

      def queue_refresh_content_host_status
        if !new_record? && !build && self.changes.key?('build')
          queue.create(id: "refresh_content_host_status_#{id}", name: _("Refresh Content Host Statuses for %s") % self,
            priority: 300, action: [self, :refresh_content_host_status])
        end
      end

      def reset_katello_status
        self.host_statuses.where(type: ::Katello::HostStatusManager::STATUSES.map(&:name)).each do |status|
          status.update!(:status => status.class.const_get(:UNKNOWN))
        end
        self.host_statuses.reload
        true
      end

      def reset_content_host_status
        logger.debug "Scheduling host status cleanup"
        queue.create(id: "reset_content_host_status_#{id}", name: _("Mark Content Host Statuses as Unknown for %s") % self,
          priority: 200, action: [self, :reset_katello_status])
      end

      def queue_reset_content_host_status
        should_reset_content_host_status? && reset_content_host_status
      end

      def should_reset_content_host_status?
        return false unless self.is_a?(::Host::Base)
        !new_record? && build && self.changes.key?('build')
      end

      module ClassMethods
        def find_by_installed_debs(_key, _operator, value)
          name, architecture, version = Katello::Deb.split_nav(value)
          debs = Katello::InstalledDeb.where(:name => name)
          debs = debs.where(:architecture => architecture) unless architecture.nil?
          debs = debs.where(:version => version) unless version.nil?
          hosts = debs.joins(:host_installed_debs).select("#{Katello::HostInstalledDeb.table_name}.host_id as host_id").pluck(:host_id)
          if hosts.empty?
            {
              :conditions => "1=0"
            }
          else
            {
              :conditions => "#{::Host::Managed.table_name}.id IN (#{hosts.join(',')})"
            }
          end
        end
      end

      def correct_kickstart_repository
        return unless content_facet

        # If switched from ks repo to install media:
        if medium_id_changed? && medium && content_facet.kickstart_repository
          content_facet.kickstart_repository_id = nil
        # If switched from install media to ks repo:
        elsif content_facet.kickstart_repository && medium
          self.medium = nil
        end
      end

      def rhsm_organization_label
        self.organization.label
      end

      def rhsm_fact_values
        self.fact_values.joins(:fact_name).where("#{::FactName.table_name}.type = '#{Katello::RhsmFactName}'")
      end

      def self.available_locks
        [:update]
      end

      def import_package_profile(simple_packages)
        found = import_package_profile_in_bulk(simple_packages)
        sync_package_associations(found.map(&:id).uniq)
      end

      def import_package_profile_in_bulk(simple_packages)
        nvreas = simple_packages.map { |sp| sp.nvrea }
        found_nvrea = InstalledPackage.where(:nvrea => nvreas)
        nil_vendor_installed_packages = found_nvrea.where(vendor: nil)
        unless nil_vendor_installed_packages.blank?
          packages_to_update = simple_packages.select { |sp| !sp.vendor.blank? && nil_vendor_installed_packages&.map(&:nvrea)&.include?(sp.nvrea) }
          packages_to_update.each do |simple_package|
            nil_vendor_installed_packages.where(nvrea: simple_package.nvrea).update(vendor: simple_package.vendor)
          end
        end

        found = found_nvrea.select(:id, :nvrea).to_a
        found_nvreas = found.map(&:nvrea)

        new_packages = simple_packages.select { |sp| !found_nvreas.include?(sp.nvrea) }

        installed_packages = []
        new_packages.each do |simple_package|
          installed_packages << InstalledPackage.new(:nvrea => simple_package.nvrea,
                                          :nvra => simple_package.nvra,
                                          :name => simple_package.name,
                                          :epoch => simple_package.epoch,
                                          :version => simple_package.version,
                                          :release => simple_package.release,
                                          :arch => simple_package.arch,
                                          :vendor => simple_package.vendor)
        end
        InstalledPackage.import(installed_packages, validate: false, on_duplicate_key_ignore: true)
        #re-lookup all imported to pickup any duplicates/conflicts
        imported = InstalledPackage.where(:nvrea => installed_packages.map(&:nvrea)).select(:id).to_a

        if imported.count != installed_packages.count
          Rails.logger.warn("Mismatch found in installed package insertion, expected #{installed_packages.count} but only could find #{imported.count}.  This is most likley a bug.")
        end

        (found + imported).flatten
      end

      def import_enabled_repositories(repos)
        paths = repos.map do |repo|
          if !repo['baseurl'].blank?
            URI(repo['baseurl'].first).path
          else
            logger.warn("System #{name} (#{id}) attempted to bind to unspecific repo (#{repo}).")
            nil
          end
        end
        content_facet.update_repositories_by_paths(paths.compact)
      end

      def import_module_streams(module_streams)
        streams = {}
        module_streams.each do |module_stream|
          stream = AvailableModuleStream.create_or_find_by!(name: module_stream["name"],
                                               context: module_stream["context"],
                                               stream: module_stream["stream"])
          streams[stream.id] = module_stream
        end
        sync_available_module_stream_associations(streams)
      end

      def sync_available_module_stream_associations(new_available_module_streams)
        upgradable_streams = self.host_available_module_streams.where(:available_module_stream_id => new_available_module_streams.keys)
        old_associated_ids = self.available_module_stream_ids
        delete_ids = old_associated_ids - new_available_module_streams.keys

        if delete_ids.any?
          self.host_available_module_streams.where(:available_module_stream_id => delete_ids).delete_all
        end

        new_ids = new_available_module_streams.keys - old_associated_ids
        new_ids.each do |new_id|
          module_stream = new_available_module_streams[new_id]
          status = module_stream["status"]
          # Set status to "unknown" only if the active field is in use and set to false and the module is enabled
          if enabled_module_stream_inactive?(module_stream)
            status = "unknown"
          end
          self.host_available_module_streams.create!(host_id: self.id,
                                                     available_module_stream_id: new_id,
                                                     installed_profiles: module_stream["installed_profiles"],
                                                     status: status)
        end

        upgradable_streams.each do |hams|
          module_stream = new_available_module_streams[hams.available_module_stream_id]
          shared_keys = hams.attributes.keys & module_stream.keys
          module_stream_data = module_stream.slice(*shared_keys)
          if hams.attributes.slice(*shared_keys) != module_stream_data
            hams.update!(module_stream_data)
          end
          # Set status to "unknown" only if the active field is in use and set to false and the module is enabled
          if enabled_module_stream_inactive?(module_stream)
            hams.update!(status: "unknown")
          end
        end
      end

      def sync_package_associations(new_installed_package_ids)
        Katello::Util::Support.active_record_retry do
          old_associated_ids = self.reload.installed_package_ids
          table_name = self.host_installed_packages.table_name

          new_ids = new_installed_package_ids - old_associated_ids
          delete_ids = old_associated_ids - new_installed_package_ids

          queries = []

          if delete_ids.any?
            queries << "DELETE FROM #{table_name} WHERE host_id=#{self.id} AND installed_package_id IN (#{delete_ids.join(', ')})"
          end

          unless new_ids.empty?
            inserts = new_ids.map { |unit_id| "(#{unit_id.to_i}, #{self.id.to_i})" }
            queries << "INSERT INTO #{table_name} (installed_package_id, host_id) VALUES #{inserts.join(', ')}"
          end

          queries.each do |query|
            ActiveRecord::Base.connection.execute(query)
          end
        end
      end

      def import_tracer_profile(tracer_profile)
        traces = []
        tracer_profile.each do |trace, attributes|
          next if attributes[:helper].blank?

          traces << { host_id: self.id, application: trace, helper: attributes[:helper], app_type: attributes[:type] }
        end
        host_traces.delete_all
        Katello::HostTracer.import(traces, validate: false)
        update_trace_status
      end

      def subscription_status
        @subscription_status ||= get_status(::Katello::SubscriptionStatus).status
      end

      def subscription_status_label(options = {})
        @subscription_status_label ||= get_status(::Katello::SubscriptionStatus).to_label(options)
      end

      def subscription_global_status
        @subscription_global_status ||= get_status(::Katello::SubscriptionStatus).to_global
      end

      def errata_status
        @errata_status ||= get_status(::Katello::ErrataStatus).status
      end

      def errata_status_label(options = {})
        @errata_status_label ||= get_status(::Katello::ErrataStatus).to_label(options)
      end

      def purpose_status
        @purpose_status ||= get_status(::Katello::PurposeStatus).status
      end

      def purpose_status_label(options = {})
        @purpose_status_label ||= get_status(::Katello::PurposeStatus).to_label(options)
      end

      def purpose_sla_status
        @purpose_sla_status ||= get_status(::Katello::PurposeSlaStatus).status
      end

      def purpose_sla_status_label(options = {})
        @purpose_sla_status_label ||= get_status(::Katello::PurposeSlaStatus).to_label(options)
      end

      def purpose_role_status
        @purpose_role_status ||= get_status(::Katello::PurposeRoleStatus).status
      end

      def purpose_role_status_label(options = {})
        @purpose_role_status_label ||= get_status(::Katello::PurposeRoleStatus).to_label(options)
      end

      def purpose_usage_status
        @purpose_usage_status ||= get_status(::Katello::PurposeUsageStatus).status
      end

      def purpose_usage_status_label(options = {})
        @purpose_usage_status_label ||= get_status(::Katello::PurposeUsageStatus).to_label(options)
      end

      def purpose_addons_status
        @purpose_addons_status ||= get_status(::Katello::PurposeAddonsStatus).status
      end

      def purpose_addons_status_label(options = {})
        @purpose_addons_status_label ||= get_status(::Katello::PurposeAddonsStatus).to_label(options)
      end

      def traces_status
        @traces_status ||= get_status(::Katello::TraceStatus).status
      end

      def traces_status_label(options = {})
        @traces_status_label ||= get_status(::Katello::TraceStatus).to_label(options)
      end

      def traces_helpers(search:)
        traces = host_traces.selectable.search_for(search)
        ::Katello::HostTracer.helpers_for(traces)
      end

      def package_names_for_job_template(action:, search:, versions: nil)
        actions = %w(install remove update).freeze
        case action
        when 'install'
          ::Katello::Rpm.yum_installable_for_host(self).search_for(search).distinct.pluck(:name)
        when 'remove'
          return [] if search.empty?

          installed_packages.search_for(search).distinct.pluck(:name)
        when 'update'
          return [] if search.empty?

          versions_by_name = {}
          if versions.present?
            JSON.parse(versions).each do |nvra|
              nvra =~ /([^.]*)-\d+\.[-.\w]*/
              versions_by_name[Regexp.last_match(1)] = nvra
            end
          end
          pkg_names = installed_packages.search_for(search).distinct.pluck(:name)
          upgrades = ::Katello::Rpm.installable_for_hosts([self]).select(:id, :name, :nvra, :evr).order(evr: :desc).group_by(&:name)
          pkg_names.map { |p| versions_by_name[p] || upgrades[p]&.first&.nvra }.compact
        else
          fail ::Foreman::Exception.new(N_("package_names_for_job_template: Action must be one of %s"), actions.join(', '))
        end
      end

      def advisory_ids(search:)
        ::Katello::Erratum.installable_for_hosts([self]).search_for(search).pluck(:errata_id)
      end

      def filtered_entitlement_quantity_consumed(pool)
        entitlements = subscription_facet.candlepin_consumer.filter_entitlements(pool.cp_id)
        return nil if entitlements.empty?
        entitlements.sum { |e| e[:quantity] }
      end

      protected

      def update_trace_status
        self.get_status(::Katello::TraceStatus).refresh!
        self.refresh_global_status!
      end

      def enabled_module_stream_inactive?(module_stream)
        !module_stream["active"].nil? && module_stream["active"] == false && module_stream["status"] == "enabled"
      end
    end
  end
end

class ::Host::Managed::Jail < Safemode::Jail
  allow :content_source, :subscription_manager_configuration_url, :rhsm_organization_label,
        :host_collections, :pools, :hypervisor_host, :installed_debs,
        :installed_packages, :traces_helpers, :advisory_ids, :package_names_for_job_template,
        :filtered_entitlement_quantity_consumed, :bound_repositories,
        :single_content_view, :single_lifecycle_environment
end

class ActiveRecord::Associations::CollectionProxy::Jail < Safemode::Jail
  allow :expiring_in_days
end
