module Katello
  module Host
    class ContentFacet < Katello::Model
      audited :associated_with => :host
      self.table_name = 'katello_content_facets'
      include Facets::Base

      HOST_TOOLS_PACKAGE_NAME = 'katello-host-tools'.freeze
      HOST_TOOLS_TRACER_PACKAGE_NAME = 'katello-host-tools-tracer'.freeze
      SUBSCRIPTION_MANAGER_PACKAGE_NAME = 'subscription-manager'.freeze

      belongs_to :kickstart_repository, :class_name => "::Katello::Repository", :inverse_of => :kickstart_content_facets
      belongs_to :content_source, :class_name => "::SmartProxy", :inverse_of => :content_facets

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
      validates_associated :content_view_environment_content_facets
      validates :host, :presence => true, :allow_blank => false

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
        self.cves_changed = true
      end

      def mark_cves_unchanged
        self.cves_changed = false
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

      def assign_single_environment(
        content_view_id: nil, lifecycle_environment_id: nil, environment_id: nil,
        content_view: nil, lifecycle_environment: nil, environment: nil
      )
        lifecycle_environment_id ||= environment_id || lifecycle_environment&.id || environment&.id
        content_view_id ||= content_view&.id

        unless lifecycle_environment_id
          fail _("Lifecycle environment must be specified")
        end

        unless content_view_id
          fail _("Content view must be specified")
        end

        content_view_environment = ::Katello::ContentViewEnvironment
          .where(:content_view_id => content_view_id, :environment_id => lifecycle_environment_id)
          .first_or_create do |cve|
          Rails.logger.info("ContentViewEnvironment not found for content view '#{cve.content_view_name}' and environment '#{cve.environment&.name}'; creating a new one.")
        end
        fail _("Unable to create ContentViewEnvironment. Check the logs for more information.") if content_view_environment.nil?

        self.content_view_environments = [content_view_environment]
      end

      def default_environment?
        content_view_environments.any? do |cve|
          cve.content_view.default? && cve.lifecycle_environment.library?
        end
      end

      def update_repositories_by_paths(paths)
        prefixes = %w(/pulp/deb/ /pulp/repos/ /pulp/content/)
        relative_paths = []

        # paths == ["/pulp/content/Default_Organization/Library/custom/Test_product/test2"]
        paths.each do |path|
          if (prefix = prefixes.find { |pre| path.start_with?(pre) })
            relative_paths << path.gsub(prefix, '')
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
          :enhancement => installable_enhancement_errata_count
        }
        installable_hash[:total] = installable_hash.values.inject(:+)
        # same for applicable, but we need to get the counts from the db
        applicable_hash = {
          :security => applicable_errata.security.count,
          :bugfix => applicable_errata.bugfix.count,
          :enhancement => applicable_errata.enhancement.count
        }
        applicable_hash[:total] = applicable_hash.values.inject(:+)
        # keeping installable at the top level for backward compatibility
        installable_hash.merge({
                                 :applicable => applicable_hash
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
        self.host&.refresh_statuses(::Katello::HostStatusManager::STATUSES)
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

      def self.in_content_views_and_environments(content_views: nil, lifecycle_environments: nil)
        relation = self.joins(:content_view_environment_content_facets => :content_view_environment)
        relation = relation.where("#{::Katello::ContentViewEnvironment.table_name}.content_view_id" => content_views) if content_views
        relation = relation.where("#{::Katello::ContentViewEnvironment.table_name}.environment_id" => lifecycle_environments) if lifecycle_environments
        relation
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

      def tracer_installed?
        self.host.installed_packages.where("#{Katello::InstalledPackage.table_name}.name" => [ "python-#{HOST_TOOLS_TRACER_PACKAGE_NAME}",
                                                                                               "python3-#{HOST_TOOLS_TRACER_PACKAGE_NAME}",
                                                                                               HOST_TOOLS_TRACER_PACKAGE_NAME ]).any? ||
          self.host.installed_debs.where("#{Katello::InstalledDeb.table_name}.name" => [ "python-#{HOST_TOOLS_TRACER_PACKAGE_NAME}",
                                                                                         "python3-#{HOST_TOOLS_TRACER_PACKAGE_NAME}",
                                                                                         HOST_TOOLS_TRACER_PACKAGE_NAME ]).any?
      end

      def host_tools_installed?
        host.installed_packages.where("#{Katello::InstalledPackage.table_name}.name" => [ "python-#{HOST_TOOLS_PACKAGE_NAME}",
                                                                                          "python3-#{HOST_TOOLS_PACKAGE_NAME}",
                                                                                          HOST_TOOLS_PACKAGE_NAME ]).any? ||
          host.installed_debs.where("#{Katello::InstalledDeb.table_name}.name" => [ "python-#{HOST_TOOLS_PACKAGE_NAME}",
                                                                                    "python3-#{HOST_TOOLS_PACKAGE_NAME}",
                                                                                    HOST_TOOLS_PACKAGE_NAME ]).any?
      end

      def update_errata_status
        host.get_status(::Katello::ErrataStatus).refresh!
        host.refresh_global_status!
      end

      # TODO: uncomment when we need to display multiple CVE names in the UI
      # def content_view_environment_names
      #   content_view_environments.map(&:candlepin_name).join(', ')
      # end

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
              :single_content_view, :single_lifecycle_environment
      end
    end
  end
end
