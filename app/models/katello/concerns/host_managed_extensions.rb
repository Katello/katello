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
      end

      included do
        prepend Overrides

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

        before_save :correct_puppet_environment
        before_validation :correct_kickstart_repository

        scoped_search :relation => :host_collections, :on => :id, :complete_value => false, :rename => :host_collection_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
        scoped_search :relation => :host_collections, :on => :name, :complete_value => true, :rename => :host_collection
        scoped_search :relation => :installed_packages, :on => :nvra, :complete_value => true, :rename => :installed_package, :only_explicit => true
        scoped_search :relation => :installed_packages, :on => :name, :complete_value => true, :rename => :installed_package_name, :only_explicit => true
        scoped_search :relation => :available_module_streams, :on => :name, :complete_value => true, :rename => :available_module_stream_name, :only_explicit => true
        scoped_search :relation => :available_module_streams, :on => :stream, :complete_value => true, :rename => :available_module_stream_stream, :only_explicit => true
        scoped_search :relation => :installed_debs, :on => :name, :complete_value => true, :rename => :installed_package_name, :only_explicit => true
        scoped_search :relation => :host_traces, :on => :application, :complete_value => true, :rename => :trace_app, :only_explicit => true
        scoped_search :relation => :host_traces, :on => :app_type, :complete_value => true, :rename => :trace_app_type, :only_explicit => true
        scoped_search :relation => :host_traces, :on => :helper, :complete_value => true, :rename => :trace_helper, :only_explicit => true
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

      def correct_puppet_environment
        if content_and_puppet_matched?
          new_environment = content_facet.content_view.puppet_env(content_facet.lifecycle_environment).try(:puppet_environment)
          self.environment = new_environment if new_environment
        end
      end

      def content_and_puppet_matched?
        content_facet && content_facet.content_view_id_was == environment.try(:content_view).try(:id) &&
          content_facet.lifecycle_environment_id_was == self.environment.try(:lifecycle_environment).try(:id)
      end

      def content_and_puppet_match?
        content_facet && content_facet.content_view_id == environment.try(:content_view).try(:id) &&
          content_facet.lifecycle_environment_id == self.environment.try(:lifecycle_environment).try(:id)
      end

      def import_package_profile(simple_packages)
        found = import_package_profile_in_bulk(simple_packages)
        sync_package_associations(found.map(&:id))
      end

      def import_package_profile_in_bulk(simple_packages)
        nvreas = simple_packages.map { |sp| sp.nvrea }
        found = InstalledPackage.where(:nvrea => nvreas).select(:id, :nvrea).to_a
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
                                          :arch => simple_package.arch)
        end
        InstalledPackage.import(installed_packages, validate: false, on_duplicate_key_ignore: true)

        found << installed_packages
        found.flatten
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
          stream = AvailableModuleStream.where(name: module_stream["name"],
                                               stream: module_stream["stream"]).first_or_create!
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
          self.host_available_module_streams.create!(host_id: self.id,
                                                     available_module_stream_id: new_id,
                                                     installed_profiles: module_stream["installed_profiles"],
                                                     status: module_stream["status"])
        end

        upgradable_streams.each do |hams|
          module_stream = new_available_module_streams[hams.available_module_stream_id]
          shared_keys = hams.attributes.keys & module_stream.keys
          module_stream_data = module_stream.slice(*shared_keys)
          if hams.attributes.slice(*shared_keys) != module_stream_data
            hams.update_attributes!(module_stream_data)
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
        self.host_traces.destroy_all
        tracer_profile.each do |trace, attributes|
          self.host_traces.create!(:application => trace, :helper => attributes[:helper], :app_type => attributes[:type])
        end
        self.update_trace_status
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

      def valid_content_override_label?(content_label)
        available_content = subscription_facet.candlepin_consumer.available_product_content
        available_content.map(&:content).any? { |content| content.label == content_label }
      end

      protected

      def update_trace_status
        self.get_status(::Katello::TraceStatus).refresh!
        self.refresh_global_status!
      end
    end
  end
end

class ::Host::Managed::Jail < Safemode::Jail
  allow :content_source, :subscription_manager_configuration_url, :rhsm_organization_label,
        :host_collections, :comment, :pools, :hypervisor_host, :lifecycle_environment, :content_view,
        :installed_packages
end
