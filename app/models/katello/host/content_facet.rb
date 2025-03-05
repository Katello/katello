module Katello
  module Host
    # rubocop:disable Metrics/ClassLength
    class ContentFacet < Katello::Model
      audited :associated_with => :host
      self.table_name = 'katello_content_facets'
      include Facets::Base

      HOST_TOOLS_PACKAGE_NAME = 'katello-host-tools'.freeze
      HOST_TOOLS_TRACER_PACKAGE_NAME = 'katello-host-tools-tracer'.freeze
      SUBSCRIPTION_MANAGER_PACKAGE_NAME = 'subscription-manager'.freeze
      ALL_HOST_TOOLS_PACKAGE_NAMES = [ "python-#{HOST_TOOLS_PACKAGE_NAME}",
                                       "python3-#{HOST_TOOLS_PACKAGE_NAME}",
                                       HOST_TOOLS_PACKAGE_NAME ].freeze
      ALL_TRACER_PACKAGE_NAMES = [ "python-#{HOST_TOOLS_TRACER_PACKAGE_NAME}",
                                   "python3-#{HOST_TOOLS_TRACER_PACKAGE_NAME}",
                                   HOST_TOOLS_TRACER_PACKAGE_NAME ].freeze
      BOOTC_FIELD_FACT_NAMES = [
        "bootc.booted.image",
        "bootc.booted.digest",
        "bootc.staged.image",
        "bootc.staged.digest",
        "bootc.rollback.image",
        "bootc.rollback.digest",
        "bootc.available.image",
        "bootc.available.digest",
      ].freeze

      belongs_to :kickstart_repository, :class_name => "::Katello::Repository", :inverse_of => :kickstart_content_facets
      belongs_to :content_source, :class_name => "::SmartProxy", :inverse_of => :content_facets
      belongs_to :manifest_entity, :polymorphic => true, :optional => true, :inverse_of => :content_facets

      has_many :content_view_environment_content_facets, :class_name => "Katello::ContentViewEnvironmentContentFacet", :dependent => :destroy, :inverse_of => :content_facet
      has_many :content_view_environments, :through => :content_view_environment_content_facets,
               :class_name => "Katello::ContentViewEnvironment", :source => :content_view_environment,
               :after_add => :mark_cves_changed, :after_remove => :mark_cves_changed
      has_many :content_views, :through => :content_view_environments, :class_name => "Katello::ContentView"
      has_many :lifecycle_environments, :through => :content_view_environments, :class_name => "Katello::KTEnvironment"

      has_many :content_facet_errata, :class_name => "Katello::ContentFacetErratum", :dependent => :delete_all, :inverse_of => :content_facet
      has_many :applicable_errata, :through => :content_facet_errata, :class_name => "Katello::Erratum", :source => :erratum

      has_many :content_facet_repositories, :class_name => "Katello::ContentFacetRepository", :dependent => :destroy, :inverse_of => :content_facet
      has_many :bound_repositories, :through => :content_facet_repositories, :class_name => "Katello::Repository", :source => :repository
      has_many :bound_content, :through => :bound_repositories, :class_name => "Katello::Content", :source => :content
      has_many :bound_root_repositories, :through => :bound_repositories, :class_name => "Katello::RootRepository", :source => :root

      has_many :content_facet_applicable_debs, :class_name => "Katello::ContentFacetApplicableDeb", :dependent => :delete_all, :inverse_of => :content_facet
      has_many :applicable_debs, :through => :content_facet_applicable_debs, :class_name => "Katello::Deb", :source => :deb

      has_many :content_facet_applicable_rpms, :class_name => "Katello::ContentFacetApplicableRpm", :dependent => :delete_all, :inverse_of => :content_facet
      has_many :applicable_rpms, :through => :content_facet_applicable_rpms, :class_name => "Katello::Rpm", :source => :rpm

      has_many :content_facet_applicable_module_streams, :class_name => "Katello::ContentFacetApplicableModuleStream", :dependent => :delete_all, :inverse_of => :content_facet
      has_many :applicable_module_streams, :through => :content_facet_applicable_module_streams, :class_name => "Katello::ModuleStream", :source => :module_stream

      validates_with ::AssociationExistsValidator, attributes: [:content_source]
      validates_with Katello::Validators::GeneratedContentViewValidator
      validates_associated :content_view_environment_content_facets, :message => _("invalid: The content source must sync the lifecycle environment assigned to the host. See the logs for more information.")
      validates :host, :presence => true, :allow_blank => false
      validates :bootc_booted_digest, :bootc_available_digest, :bootc_staged_digest, :bootc_rollback_digest,
                format: { with: /\Asha256:[A-Fa-f0-9]{64}\z/, message: "must be a valid sha256 digest", allow_blank: true }

      scope :with_environments, ->(lifecycle_environments) do
        joins(:content_view_environment_content_facets => :content_view_environment).
          where("#{::Katello::ContentViewEnvironment.table_name}.environment_id" => lifecycle_environments)
      end

      scope :with_content_views, ->(content_views) do
        joins(:content_view_environment_content_facets => :content_view_environment).
          where("#{::Katello::ContentViewEnvironment.table_name}.content_view_id" => content_views)
      end

      scope :with_content_view_environments, ->(content_view_environments) do
        joins(:content_view_environment_content_facets => :content_view_environment).
          where("#{::Katello::ContentViewEnvironment.table_name}.id" => content_view_environments)
      end

      attr_accessor :cves_changed

      def initialize(*args)
        init_args = args.first || {}
        env_id = init_args.delete(:lifecycle_environment_id)
        cv_id = init_args.delete(:content_view_id)
        super(*args)
        if env_id && cv_id
          assign_single_environment(
            lifecycle_environment_id: env_id,
            content_view_id: cv_id
          )
        end
        self.cves_changed = false
      end

      def mark_cves_changed(_cve)
        Rails.logger.debug("ContentFacet: Marking CVEs changed for host #{host&.to_label}")
        self.cves_changed = true
      end

      def mark_cves_unchanged
        self.cves_changed = false
      end

      def image_mode_host?
        bootc_booted_image.present?
      end

      def cves_changed?
        cves_changed
      end

      def multi_content_view_environment?
        # returns false if there are no content view environments
        content_view_environments.size > 1
      end

      def single_content_view_environment?
        # also returns false if there are no content view environments
        content_view_environments.size == 1
      end

      def single_content_view
        if multi_content_view_environment?
          Rails.logger.warn _("Content facet for host %s has more than one content view. Use #content_views instead.") % host.name
        end
        content_view_environments&.first&.content_view
      end

      def single_lifecycle_environment
        if multi_content_view_environment?
          Rails.logger.warn _("Content facet for host %s has more than one lifecycle environment. Use #lifecycle_environments instead.") % host.name
        end
        content_view_environments&.first&.lifecycle_environment
      end

      def content_view_environments=(new_cves)
        if new_cves.length > 1 && !Setting['allow_multiple_content_views']
          fail ::Katello::Errors::MultiEnvironmentNotSupportedError,
          _("Assigning a host to multiple content view environments is not enabled. To enable, set the allow_multiple_content_views setting.")
        end
        super(new_cves)
        Katello::ContentViewEnvironmentContentFacet.reprioritize_for_content_facet(self, new_cves)
        self.content_view_environments.reload unless self.new_record?
        self.host&.update_candlepin_associations unless self.host&.new_record?
      end

      def content_view_environment_labels
        content_view_environments.map(&:label).join(',')
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def assign_single_environment(
        content_view_id: nil, lifecycle_environment_id: nil, environment_id: nil,
        content_view: nil, lifecycle_environment: nil, environment: nil
      )
        lifecycle_environment_id ||= environment_id || lifecycle_environment&.id || environment&.id || self.single_lifecycle_environment&.id
        content_view_id ||= content_view&.id || self.single_content_view&.id

        unless lifecycle_environment_id
          fail _("Lifecycle environment must be specified")
        end

        unless content_view_id
          fail _("Content view must be specified")
        end

        content_view_environment = ::Katello::ContentViewEnvironment
          .find_by(:content_view_id => content_view_id, :environment_id => lifecycle_environment_id)
        if content_view_environment.nil?
          env_label = ::Katello::KTEnvironment.find_by(:id => lifecycle_environment_id)&.label
          fail ::Katello::Errors::ContentViewEnvironmentError, _("Unable to find a lifecycle environment with ID %s") % lifecycle_environment_id if env_label.nil?
          cv_label = ::Katello::ContentView.find_by(:id => content_view_id)&.label
          fail ::Katello::Errors::ContentViewEnvironmentError, _("Unable to find a content view with ID %s") % content_view_id if cv_label.nil?
          hypothetical_cve_label = "%s/%s" % [env_label, cv_label]
          fail ::Katello::Errors::ContentViewEnvironmentError, _("Cannot assign content view environment %s: The content view has either not been published or has not been promoted to that lifecycle environment.") % hypothetical_cve_label
        end

        self.content_view_environments = [content_view_environment]
      end

      def default_environment?
        return if content_view_environments.blank?
        # if default cve is first, this is equivalent to default being the only one.
        # if default cve is not first, candlepin will prioritize CV repos over library repos in case of conflicts.
        content_view_environments.first.default_environment?
      end

      def update_repositories_by_paths(paths)
        prefixes = %w(/pulp/deb/ /pulp/repos/ /pulp/content/)
        relative_paths = []

        # paths == ["/pulp/content/Default_Organization/Library/custom/Test_product/test2",
        #           "/pulp/content/Org/Library/custom/Test_product/test2/%3Fcomp%3Dmain%26rel%3Dstable"]
        paths.each do |path|
          if (prefix = prefixes.find { |pre| path.start_with?(pre) })
            # strip prefix and structured_apt postfix before adding to relative_paths
            relative_paths << path.sub(prefix, '').sub(%r{/?(%3F|\?).*}, '')
          else
            Rails.logger.warn("System #{self.host.name} (#{self.host.id}) requested binding to repo with unknown prefix. #{path}")
          end
        end

        repos = Repository.where(relative_path: relative_paths)
        relative_paths -= repos.pluck(:relative_path) # remove relative paths that match our repos

        # Any leftover relative paths do not match the repos we've just retrieved from the db,
        # so we should log warnings about them.
        relative_paths.each do |repo_path|
          Rails.logger.warn("System #{self.host.name} (#{self.host.id}) requested binding to unknown repo #{repo_path}")
        end

        unless self.bound_repositories.sort == repos.sort
          self.bound_repositories = repos
          self.save!
        end
        self.bound_repositories.pluck(:relative_path)
      end

      def installable_errata(env = nil, content_view = nil)
        Erratum.installable_for_content_facet(self, env, content_view)
      end

      def installable_debs(env = nil, content_view = nil)
        Deb.installable_for_content_facet(self, env, content_view)
      end

      def installable_rpms(env = nil, content_view = nil)
        Rpm.installable_for_content_facet(self, env, content_view)
      end

      def installable_module_streams(env = nil, content_view = nil)
        ModuleStream.installable_for_content_facet(self, env, content_view)
      end

      def errata_counts
        installable_hash = {
          :security => installable_security_errata_count,
          :bugfix => installable_bugfix_errata_count,
          :enhancement => installable_enhancement_errata_count,
        }
        installable_hash[:total] = installable_hash.values.inject(:+)
        # same for applicable, but we need to get the counts from the db
        applicable_errata_counts = applicable_errata.pluck(:errata_type).tally
        applicable_hash = {
          :bugfix => applicable_errata_counts.values_at(*Katello::Erratum::BUGZILLA).compact.sum,
          :security => applicable_errata_counts.values_at(*Katello::Erratum::SECURITY).compact.sum,
          :enhancement => applicable_errata_counts.values_at(*Katello::Erratum::ENHANCEMENT).compact.sum,
        }
        applicable_hash[:total] = applicable_errata_counts.values.sum

        # keeping installable at the top level for backward compatibility
        installable_hash.merge({
                                 :applicable => applicable_hash,
                               })
      end

      def self.trigger_applicability_generation(host_ids)
        host_ids = [host_ids] unless host_ids.is_a?(Array)
        ::Katello::ApplicableHostQueue.push_hosts(host_ids)
        ::Katello::EventQueue.push_event(::Katello::Events::GenerateHostApplicability::EVENT_TYPE, 0)
      end

      # Katello applicability
      def calculate_and_import_applicability
        bound_repos = bound_repositories.collect do |repo|
          repo.library_instance_id.nil? ? repo.id : repo.library_instance_id
        end

        ::Katello::Applicability::ApplicableContentHelper.new(self, ::Katello::Deb, bound_repos).calculate_and_import
        ::Katello::Applicability::ApplicableContentHelper.new(self, ::Katello::Rpm, bound_repos).calculate_and_import
        ::Katello::Applicability::ApplicableContentHelper.new(self, ::Katello::Erratum, bound_repos).calculate_and_import
        ::Katello::Applicability::ApplicableContentHelper.new(self, ::Katello::ModuleStream, bound_repos).calculate_and_import
        update_applicability_counts
        self.host&.refresh_statuses([::Katello::ErrataStatus, ::Katello::RhelLifecycleStatus])
      end

      def update_applicability_counts
        self.assign_attributes(
            :installable_security_errata_count => self.installable_errata.security.count,
            :installable_bugfix_errata_count => self.installable_errata.bugfix.count,
            :installable_enhancement_errata_count => self.installable_errata.enhancement.count,
            :applicable_deb_count => self.content_facet_applicable_debs.count,
            :upgradable_deb_count => self.installable_debs.count,
            :applicable_rpm_count => self.content_facet_applicable_rpms.count,
            :upgradable_rpm_count => self.installable_rpms.count,
            :applicable_module_stream_count => self.content_facet_applicable_module_streams.count,
            :upgradable_module_stream_count => self.installable_module_streams.count
        )
        self.save!(:validate => false)
      end

      def self.in_content_view_version_environments(version_environments)
        # takes a structure of [{:content_view_version => ContentViewVersion, :environments => [KTEnvironment]}]
        relation = self.joins(:content_view_environment_content_facets => :content_view_environment)
        queries = version_environments.map do |version_environment|
          version = version_environment[:content_view_version]
          env_ids = version_environment[:environments].map(&:id)
          "(#{::Katello::ContentViewEnvironment.table_name}.content_view_version_id = #{version.id} AND #{::Katello::ContentViewEnvironment.table_name}.environment_id IN (#{env_ids.join(',')}))"
        end
        relation.where(queries.join(" OR "))
      end

      def self.with_non_installable_errata(errata, hosts = nil)
        content_facets = Katello::Host::ContentFacet.select(:id).where(:host_id => hosts)
        reachable_repos = ::Katello::ContentFacetRepository.where(content_facet_id: content_facets).distinct.pluck(:repository_id)
        installable_errata = ::Katello::ContentFacetErratum.select(:id).
          where(content_facet_id: content_facets).
          joins(
          "inner join #{::Katello::RepositoryErratum.table_name} ON #{Katello::ContentFacetErratum.table_name}.erratum_id = #{Katello::RepositoryErratum.table_name}.erratum_id",
          "inner JOIN #{Katello::ContentFacetRepository.table_name} "\
            "ON #{Katello::ContentFacetErratum.table_name}.content_facet_id = #{Katello::ContentFacetRepository.table_name}.content_facet_id "\
            "AND #{Katello::RepositoryErratum.table_name}.repository_id = #{Katello::ContentFacetRepository.table_name}.repository_id"
          ).
          where("#{Katello::RepositoryErratum.table_name}.repository_id" => reachable_repos).
          where("#{Katello::RepositoryErratum.table_name}.erratum_id" => errata).
          where("#{Katello::ContentFacetRepository.table_name}.repository_id" => reachable_repos).
          where("#{Katello::ContentFacetRepository.table_name}.content_facet_id" => content_facets)

        non_installable_errata = ::Katello::ContentFacetErratum.select(:content_facet_id).
          where.not(id: installable_errata).
          where(content_facet_id: content_facets, erratum_id: errata)

        Katello::Host::ContentFacet.where(id: non_installable_errata)
      end

      def self.populate_fields_from_facts(host, parser, _type, _source_proxy)
        return if host.content_facet.blank?
        facet = host.content_facet || host.build_content_facet
        attrs_to_add = {}
        BOOTC_FIELD_FACT_NAMES.each do |fact_name|
          fact_value = parser.facts[fact_name]
          field_name = fact_name.tr(".", "_")
          attrs_to_add[field_name] = fact_value # overwrite with nil if fact is not present
        end
        if attrs_to_add['bootc_booted_digest'].present?
          manifest_entity = find_manifest_entity(digest: attrs_to_add['bootc_booted_digest'])
          if manifest_entity.present?
            attrs_to_add['manifest_entity_type'] = manifest_entity.model_name.name
            attrs_to_add['manifest_entity_id'] = manifest_entity.id
          else
            # remove the association if the manifest entity is not found
            attrs_to_add['manifest_entity_type'] = nil
            attrs_to_add['manifest_entity_id'] = nil
          end
        end
        facet.assign_attributes(attrs_to_add)
        facet.save unless facet.new_record?
      end

      def self.find_manifest_entity(digest:)
        ::Katello::DockerManifestList.find_by(digest: digest) || ::Katello::DockerManifest.find_by(digest: digest)
      end

      def self.with_applicable_errata(errata)
        self.joins(:applicable_errata).where("#{Katello::Erratum.table_name}.id" => errata)
      end

      def self.with_installable_errata(errata)
        joins_installable_errata.where("#{Katello::Erratum.table_name}.id" => errata)
      end

      def self.joins_installable_errata
        joins_installable_relation(Katello::Erratum, Katello::ContentFacetErratum)
      end

      def self.joins_installable_debs
        joins_installable_relation(Katello::Deb, Katello::ContentFacetApplicableDeb)
      end

      def self.joins_installable_rpms
        joins_installable_relation(Katello::Rpm, Katello::ContentFacetApplicableRpm)
      end

      def self.joins_repositories
        facet_repository = Katello::ContentFacetRepository.table_name
        root_repository = Katello::RootRepository.table_name
        repository = Katello::Repository.table_name

        self.joins("INNER JOIN #{facet_repository} on #{facet_repository}.content_facet_id = #{table_name}.id",
                   "INNER JOIN #{repository} on #{repository}.id = #{facet_repository}.repository_id",
                   "INNER JOIN #{root_repository} on #{root_repository}.id = #{repository}.root_id",
                   "INNER JOIN #{Katello::Content.table_name} on #{Katello::Content.table_name}.cp_content_id = #{root_repository}.content_id").
             where("#{facet_repository}.content_facet_id = #{self.table_name}.id")
      end

      def available_releases
        self.content_view_environments.flat_map do |cve|
          cve.content_view.version(cve.lifecycle_environment).available_releases
        end
      end

      def tracer_installed?(force_update_cache: false)
        Rails.cache.fetch("#{self.host.id}/tracer_installed", expires_in: 7.days, force: force_update_cache) do
          self.host.installed_packages.where("#{Katello::InstalledPackage.table_name}.name" => ALL_TRACER_PACKAGE_NAMES).any? ||
            self.host.installed_debs.where("#{Katello::InstalledDeb.table_name}.name" => ALL_TRACER_PACKAGE_NAMES).any?
        end
      end

      def tracer_rpm_available?
        ::Katello::Rpm.yum_installable_for_host(self.host).where(name: ALL_TRACER_PACKAGE_NAMES).any?
      end

      def host_tools_installed?(force_update_cache: false)
        Rails.cache.fetch("#{self.host.id}/host_tools_installed", expires_in: 7.days, force: force_update_cache) do
          self.host.installed_packages.where("#{Katello::InstalledPackage.table_name}.name" => ALL_HOST_TOOLS_PACKAGE_NAMES).any? ||
            self.host.installed_debs.where("#{Katello::InstalledDeb.table_name}.name" => ALL_HOST_TOOLS_PACKAGE_NAMES).any?
        end
      end

      def update_errata_status
        host.get_status(::Katello::ErrataStatus).refresh!
        host.refresh_global_status!
      end

      def self.joins_installable_relation(content_model, facet_join_model)
        facet_repository = Katello::ContentFacetRepository.table_name
        content_table = content_model.table_name
        facet_join_table = facet_join_model.table_name
        repo_join_table = content_model.repository_association_class.table_name

        self.joins("INNER JOIN #{facet_repository} on #{facet_repository}.content_facet_id = #{table_name}.id",
                   "INNER JOIN #{repo_join_table} on #{repo_join_table}.repository_id = #{facet_repository}.repository_id",
                   "INNER JOIN #{content_table} on #{content_table}.id = #{repo_join_table}.#{content_model.unit_id_field}",
                   "INNER JOIN #{facet_join_table} on #{facet_join_table}.#{content_model.unit_id_field} = #{content_table}.id").
             where("#{facet_join_table}.content_facet_id = #{self.table_name}.id")
      end

      def self.inherited_attributes(hostgroup, facet_attributes)
        facet_attributes[:kickstart_repository_id] ||= hostgroup.inherited_kickstart_repository_id
        facet_attributes[:content_view_id] ||= hostgroup.inherited_content_view_id
        facet_attributes[:lifecycle_environment_id] ||= hostgroup.inherited_lifecycle_environment_id
        facet_attributes[:content_source_id] ||= hostgroup.inherited_content_source_id
        facet_attributes
      end

      apipie :class, desc: "A class representing #{model_name.human} object" do
        name 'Content Facet'
        refs 'ContentFacet'
        sections only: %w[all additional]
        desc "Content facet is an object containing the host's content-related metadata and associations"
        property :id, Integer, desc: 'Returns ID of the facet'
        property :uuid, String, desc: 'Returns UUID of the facet'
        property :applicable_module_stream_count, Integer, desc: 'Returns applicable Module Stream count'
        property :upgradable_module_stream_count, Integer, desc: 'Returns upgradable Module Stream count'
        property :applicable_deb_count, Integer, desc: 'Returns applicable DEB count'
        property :upgradable_deb_count, Integer, desc: 'Returns upgradable DEB count'
        property :applicable_rpm_count, Integer, desc: 'Returns applicable RPM count'
        property :upgradable_rpm_count, Integer, desc: 'Returns upgradable RPM count'
        property :content_source, 'SmartProxy', desc: 'Returns Smart Proxy object as the content source'
        prop_group :katello_idname_props, Katello::Model, meta: { resource: 'content_source' }
        property :errata_counts, Hash, desc: 'Returns key=value object with errata counts, e.g. {security: 0, bugfix: 0, enhancement: 0, total: 0}'
        property :kickstart_repository, 'Repository', desc: 'Returns Kickstart repository object'
        prop_group :katello_idname_props, Katello::Model, meta: { resource: 'kickstart_repository' }
      end
      class Jail < ::Safemode::Jail
        allow :applicable_deb_count, :applicable_module_stream_count, :applicable_rpm_count, :content_source, :content_source_id, :content_source_name,
              :errata_counts, :id, :kickstart_repository, :kickstart_repository_id, :kickstart_repository_name,
              :upgradable_deb_count, :upgradable_module_stream_count, :upgradable_rpm_count, :uuid,
              :installable_security_errata_count, :installable_bugfix_errata_count, :installable_enhancement_errata_count,
              :single_content_view, :single_lifecycle_environment, :content_view_environment_labels
      end
    end
  end
end
