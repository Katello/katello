module Katello
  module Concerns
    # rubocop:disable Metrics/ModuleLength
    module HostManagedExtensions
      extend ActiveSupport::Concern
      include Katello::KatelloUrlsHelper
      include ForemanTasks::Concerns::ActionSubject

      module Overrides
        def check_cve_attributes(attrs)
          if attrs[:content_facet_attributes]
            cv_id = attrs[:content_facet_attributes].delete(:content_view_id)
            lce_id = attrs[:content_facet_attributes].delete(:lifecycle_environment_id)
            # Running validations on a host will clear out any existing errors, and then
            # validate all attributes. As we know, running update or save will run validations.
            # Since we've just removed two attributes that may
            # have caused an error, we need to save those so we can explicitly validate
            # them below in add_back_cve_errors.
            @pending_cve_attrs = { content_view_id: cv_id, lifecycle_environment_id: lce_id }
            if cv_id && lce_id
              cve = content_facet&.assign_single_environment(content_view_id: cv_id, lifecycle_environment_id: lce_id)
              Rails.logger.warn "Couldn't assign content view environment; host has no content facet" if cve.blank?
              @pending_cve_attrs = {}
            end
            if (cv_id.present? && lce_id.blank?) || (cv_id.blank? && lce_id.present?)
              errors.add(:base, _("Content view and lifecycle environment must be provided together"))
            end
          end
        end

        def attributes=(attrs)
          check_cve_attributes(attrs) unless self.content_facet.blank?
          super
        end

        def update(attrs)
          check_cve_attributes(attrs) unless self.content_facet.blank?
          super
        end

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
          name = subscription_facet&.registered_through
          result = []
          if name.present?
            result = SmartProxy.with_features(provider)
                                           .authorized
                                           .where(name: name)
            if result.blank?
              result = SmartProxy.authorized.behind_load_balancer(name)
            end
          end
          proxies[:registered_through] = result
          proxies
        end
      end

      included do
        prepend ::ForemanRemoteExecution::HostExtensions
        prepend Overrides

        delegate :content_source_id, :single_content_view, :single_lifecycle_environment, :default_environment?, :single_content_view_environment?, :multi_content_view_environment?, :kickstart_repository_id, :bound_repositories,
          :installable_errata, :installable_rpms, :image_mode_host?, to: :content_facet, allow_nil: true

        delegate :release_version, :purpose_role, :purpose_usage, to: :subscription_facet, allow_nil: true

        has_many :content_view_environment_content_facets, through: :content_facet, class_name: 'Katello::ContentViewEnvironmentContentFacet'
        has_many :content_view_environments, through: :content_view_environment_content_facets
        has_many :content_views, through: :content_view_environments
        has_many :lifecycle_environments, through: :content_view_environments

        has_one :docker_manifest, through: :content_facet, source: :manifest_entity, source_type: 'Katello::DockerManifest'
        has_one :docker_manifest_list, through: :content_facet, source: :manifest_entity, source_type: 'Katello::DockerManifestList'

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

        validates :name, format: { with: Net::Validations::HOST_REGEXP, message: _("%{value} can contain only lowercase letters, numbers, dashes and dots.") }

        before_validation :correct_kickstart_repository
        after_validation :add_back_cve_errors
        after_update :clear_pending_cve_attributes
        before_update :check_host_registration, :if => proc { organization_id_changed? }

        after_validation :queue_reset_content_host_status
        register_rebuild(:queue_reset_content_host_status, N_("Content_Host_Status"))

        after_validation :queue_refresh_content_host_status
        register_rebuild(:queue_refresh_content_host_status, N_("Refresh_Content_Host_Status"))

        scope :with_pools_expiring_in_days, ->(days) { joins(:pools).merge(Katello::Pool.expiring_in_days(days)).distinct }

        scope :image_mode, -> do
          joins(:content_facet).where.not("#{::Katello::Host::ContentFacet.table_name}.bootc_booted_image" => nil)
        end

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

        smart_proxy_reference :content_facet => [:content_source_id]

        def add_back_cve_errors
          if @pending_cve_attrs&.[](:content_view_id).present? || @pending_cve_attrs&.[](:lifecycle_environment_id).present?
            check_cve_attributes({ content_facet_attributes: @pending_cve_attrs })
          end
        end

        def clear_pending_cve_attributes
          @pending_cve_attrs = {}
        end

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
      end # of included block

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
        else
          true
        end
      end

      def reset_katello_status
        self.host_statuses.where(type: ::Katello::HostStatusManager::STATUSES.map(&:name)).each do |status|
          status.update!(:status => status.class.const_get(:UNKNOWN))
        end
        self.host_statuses.reload
        true
      end

      def queue_reset_content_host_status
        if should_reset_content_host_status?
          logger.debug "Scheduling host status cleanup"
          queue.create(id: "reset_content_host_status_#{id}", name: _("Mark Content Host Statuses as Unknown for %s") % self,
            priority: 200, action: [self, :reset_katello_status])
        else
          true
        end
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
              :conditions => "1=0",
            }
          else
            {
              :conditions => "#{::Host::Managed.table_name}.id IN (#{hosts.join(',')})",
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

      def available_module_stream_id_from(name:, stream:, context:)
        @indexed_available_module_streams ||= Katello::AvailableModuleStream.all.index_by do |available_module_stream|
          "#{available_module_stream.name}-#{available_module_stream.stream}-#{available_module_stream.context}"
        end
        @indexed_available_module_streams["#{name}-#{stream}-#{context}"]&.id
      end

      def import_module_streams(module_streams)
        # module_streams looks like this
        # {"name"=>"389-ds", "stream"=>"1.4", "version"=>"8030020201203210520", "context"=>"e114a9e7", "arch"=>"x86_64", "profiles"=>[], "installed_profiles"=>[], "status"=>"default", "active"=>false}
        streams = module_streams.map do |module_stream|
          {
            name: module_stream["name"],
            stream: module_stream["stream"],
            context: module_stream["context"],
          }
        end
        if streams.any?
          AvailableModuleStream.insert_all(
            streams,
            unique_by: %w[name stream context],
            returning: %w[id name stream context]
          )
        end
        indexed_module_streams = module_streams.index_by do |module_stream|
          available_module_stream_id_from(
                  name: module_stream["name"],
                  stream: module_stream["stream"],
                  context: module_stream["context"]
                )
        end
        sync_available_module_stream_associations(indexed_module_streams)
      end

      def sync_available_module_stream_associations(new_available_module_streams)
        new_associated_ids = new_available_module_streams.keys.compact
        upgradable_streams = self.host_available_module_streams.where(:available_module_stream_id => new_associated_ids)
        old_associated_ids = self.available_module_stream_ids
        delete_ids = old_associated_ids - new_associated_ids

        if delete_ids.any?
          self.host_available_module_streams.where(:available_module_stream_id => delete_ids).delete_all
        end

        new_ids = new_associated_ids - old_associated_ids

        hams_to_create = new_ids.map do |new_id|
          module_stream = new_available_module_streams[new_id]
          status = module_stream["status"]
          # Set status to "unknown" only if the active field is in use and set to false and the module is enabled
          if enabled_module_stream_inactive?(module_stream)
            status = "unknown"
          end
          {
            host_id: self.id,
            available_module_stream_id: new_id,
            installed_profiles: module_stream["installed_profiles"],
            status: status,
          }
        end
        HostAvailableModuleStream.insert_all(hams_to_create) if hams_to_create.any?
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

      def errata_status
        @errata_status ||= get_status(::Katello::ErrataStatus).status
      end

      def errata_status_label(options = {})
        @errata_status_label ||= get_status(::Katello::ErrataStatus).to_label(options)
      end

      def rhel_lifecycle_global_status
        @rhel_lifecycle_global_status ||= get_status(::Katello::RhelLifecycleStatus).to_global
      end

      def rhel_lifecycle_status
        @rhel_lifecycle_status ||= get_status(::Katello::RhelLifecycleStatus).status
      end

      def rhel_lifecycle_status_label
        @rhel_lifecycle_status_label ||= get_status(::Katello::RhelLifecycleStatus).to_label
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

      def probably_rhel?
        # Get the os name from sub-man facts rather than operatingsystem. This is
        # less likely to have been changed by the user.
        os_name, = facts('distribution::name').values # only query for that one fact, then get its value
        # if this fact isn't there, we can ignore it because the host is not "managed"
        os_name.present? && os_name.start_with?('Red Hat Enterprise Linux')
      end

      def rhel_eos_schedule_index
        return nil unless probably_rhel?
        major = operatingsystem&.major
        return nil unless major
        return "RHEL#{major}" unless major == "7"

        arch_name = architecture&.name
        case arch_name
        when "ppc64le"
          "RHEL7 (POWER9)"
        when "aarch64"
          "RHEL7 (ARM)"
        when "s390x"
          "RHEL7 (System z (Structure A))"
        else
          "RHEL#{major}"
        end
      end

      def package_names_for_job_template(action:, search:, versions: nil)
        if self&.operatingsystem&.family == 'Debian'
          deb_names_for_job_template(action: action, search: search)
        else
          yum_names_for_job_template(action: action, search: search, versions: versions)
        end
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      def yum_names_for_job_template(action:, search:, versions: nil)
        actions = %w(install remove update).freeze
        case action
        when 'install'
          yum_installable = ::Katello::Rpm.search_for(search).distinct.pluck(:name)
          if yum_installable.empty?
            fail N_("No available packages found for search term '%s'.") % search
          end
          yum_installable
        when 'remove'
          return [] if search.empty?

          yum_removable = ::Katello::InstalledPackage.search_for(search).distinct.pluck(:name)
          if yum_removable.empty?
            fail N_("Cannot remove package(s): No installed packages found for search term '%s'.") % search
          end
          yum_removable
        when 'update'
          return [] if search.empty?

          versions_by_name_arch = {}
          if versions.present?
            JSON.parse(versions).each do |nvra|
              package_info = ::Katello::Util::Package.parse_nvrea(nvra)
              versions_by_name_arch[[package_info[:name], package_info[:arch]]] = nvra
            end
          end

          # > versions_by_name_arch
          # =>
          # {["glibc-langpack-en", "x86_64"]=>"glibc-langpack-en-2.34-100.el9_4.2.x86_64",
          #  ["crypto-policies", "noarch"]=>"crypto-policies-20221215-1.git9a18988.el9_2.1.noarch"}

          pkg_name_archs = installed_packages.search_for(search).distinct.pluck(:name, :arch)
          if pkg_name_archs.empty?
            fail _("Cannot upgrade packages: No installed packages found for search term '%s'.") % search
          end
          versionless_upgrades = ::Katello::Rpm.where(name: pkg_name_archs.map(&:first)).select(:id, :name, :arch, :evr).order(evr: :desc).group_by { |i| [i.name, i.arch] }
          # Use versions_by_name_arch if a version is specified, otherwise use the latest version. If using the latest version, upgrade by name only, not by name and arch.
          pkg_names_and_nvras = pkg_name_archs.map { |name, arch| versions_by_name_arch[[name, arch]] || versionless_upgrades[[name, arch]]&.first&.name }.compact
          if pkg_names_and_nvras.empty?
            fail _("No upgradable packages found for search term '%s'.") % search
          end
          pkg_names_and_nvras
        else
          fail ::Foreman::Exception.new(N_("package_names_for_job_template: Action must be one of %s"), actions.join(', '))
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def deb_names_for_job_template(action:, search:)
        actions = %w(install remove update).freeze
        case action
        when 'install'
          deb_installable = ::Katello::Deb.search_for(search).distinct.pluck(:name)
          if deb_installable.empty?
            fail _("No available debs found for search term '%s'. Check the host's content view environments and already-installed debs.") % search
          end
          deb_installable
        when 'remove'
          return [] if search.empty?

          ::Katello::InstalledDeb.search_for(search).distinct.pluck(:name)
        when 'update'
          return [] if search.empty?
          deb_results = ::Katello::InstalledDeb.search_for(search).distinct.pluck(:name)
          if deb_results.empty?
            fail _("No installed debs found for search term '%s'") % search
          end
          deb_results
        else
          fail ::Foreman::Exception.new(N_("deb_names_for_job_template: Action must be one of %s"), actions.join(', '))
        end
      end

      def advisory_ids(search:, check_installable_for_host: true)
        errata_scope = check_installable_for_host ? ::Katello::Erratum.installable_for_hosts([self]) : ::Katello::Erratum
        ids = errata_scope.search_for(search).pluck(:errata_id)
        if ids.empty?
          fail _("Cannot install errata: No errata found for search term '%s'") % search
        end
        ids
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
        :single_content_view, :single_lifecycle_environment, :release_version,
        :purpose_role, :purpose_usage
end

class ActiveRecord::Associations::CollectionProxy::Jail < Safemode::Jail
  allow :expiring_in_days
end
