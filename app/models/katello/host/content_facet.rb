module Katello
  module Host
    class ContentFacet < Katello::Model
      audited :associated_with => :host
      self.table_name = 'katello_content_facets'
      include Facets::Base

      belongs_to :kickstart_repository, :class_name => "::Katello::Repository", :foreign_key => :kickstart_repository_id, :inverse_of => :kickstart_content_facets
      belongs_to :content_view, :inverse_of => :content_facets, :class_name => "Katello::ContentView"
      belongs_to :lifecycle_environment, :inverse_of => :content_facets, :class_name => "Katello::KTEnvironment"
      belongs_to :content_source, :class_name => "::SmartProxy", :foreign_key => :content_source_id, :inverse_of => :content_facets

      has_many :content_facet_errata, :class_name => "Katello::ContentFacetErratum", :dependent => :delete_all, :inverse_of => :content_facet
      has_many :applicable_errata, :through => :content_facet_errata, :class_name => "Katello::Erratum", :source => :erratum

      has_many :content_facet_repositories, :class_name => "Katello::ContentFacetRepository", :dependent => :destroy, :inverse_of => :content_facet
      has_many :bound_repositories, :through => :content_facet_repositories, :class_name => "Katello::Repository", :source => :repository

      has_many :content_facet_applicable_rpms, :class_name => "Katello::ContentFacetApplicableRpm", :dependent => :delete_all, :inverse_of => :content_facet
      has_many :applicable_rpms, :through => :content_facet_applicable_rpms, :class_name => "Katello::Rpm", :source => :rpm

      has_many :content_facet_applicable_module_streams, :class_name => "Katello::ContentFacetApplicableModuleStream", :dependent => :delete_all, :inverse_of => :content_facet
      has_many :applicable_module_streams, :through => :content_facet_applicable_module_streams, :class_name => "Katello::ModuleStream", :source => :module_stream

      validates :content_view, :presence => true, :allow_blank => false
      validates :lifecycle_environment, :presence => true, :allow_blank => false
      validates_with ::AssociationExistsValidator, attributes: [:content_source]
      validates :host, :presence => true, :allow_blank => false
      validates_with Validators::ContentViewEnvironmentValidator

      def bindable_types
        [
          {
            type: Repository::DEB_TYPE,
            matcher: '/pulp/deb/',
            paths: []
          },
          {
            type: Repository::YUM_TYPE,
            matcher: '/pulp/repos/',
            paths: []
          }
        ]
      end

      def update_repositories_by_paths(paths)
        bindable_paths = bindable_types
        relative_paths = []

        paths.each do |path|
          bindable_paths.each do |supported|
            relative_path = path.gsub(supported[:matcher], '')
            relative_paths << relative_path
            if path.starts_with?(supported[:matcher])
              supported[:paths] << relative_path
              break
            end
          end
        end

        repos = bindable_paths.flat_map do |supported|
          repos = Repository.joins(:root).where(RootRepository.table_name => {content_type: supported[:type]}, relative_path: supported[:paths])
          relative_paths -= repos.pluck(:relative_path)
          repos
        end

        relative_paths.each do |repo_path|
          Rails.logger.warn("System #{self.host.name} (#{self.host.id}) requested binding to unknown repo #{repo_path}")
        end

        unless self.bound_repositories.sort == repos.sort
          update_bound_repositories(repos)
        end
        self.bound_repositories.pluck(:relative_path)
      end

      def propagate_yum_repos
        pulp_ids = self.bound_repositories.includes(:library_instance).map { |repo| repo.library_instance.try(:pulp_id) || repo.pulp_id }
        Katello::Pulp::Consumer.new(self.uuid).bind_yum_repositories(pulp_ids)
      end

      def update_bound_repositories(repos)
        self.bound_repositories = repos
        self.save!
        if SETTINGS[:katello][:katello_applicability]
          ::Katello::EventQueue.push_event(::Katello::Events::GenerateHostApplicability::EVENT_TYPE, self.host.id)
        else
          self.propagate_yum_repos
          ForemanTasks.async_task(Actions::Katello::Host::GenerateApplicability, [self.host])
        end
      end

      def installable_errata(env = nil, content_view = nil)
        ApplicableContentHelper.new(Erratum, self).installable(env, content_view)
      end

      def installable_rpms(env = nil, content_view = nil)
        ApplicableContentHelper.new(Rpm, self).installable(env, content_view)
      end

      def installable_module_streams(env = nil, content_view = nil)
        ApplicableContentHelper.new(ModuleStream, self).installable(env, content_view)
      end

      def errata_counts
        hash = {
          :security => installable_security_errata_count,
          :bugfix => installable_bugfix_errata_count,
          :enhancement => installable_enhancement_errata_count
        }
        hash[:total] = hash.values.inject(:+)
        hash
      end

      # Katello applicability
      def calculate_and_import_applicability
        bound_repos = bound_repositories.collect do |repo|
          repo.library_instance_id.nil? ? repo.id : repo.library_instance_id
        end

        ::Katello::Applicability::ApplicableContentHelper.new(self, ::Katello::Rpm, bound_repos).calculate_and_import
        ::Katello::Applicability::ApplicableContentHelper.new(self, ::Katello::Erratum, bound_repos).calculate_and_import
        ::Katello::Applicability::ApplicableContentHelper.new(self, ::Katello::ModuleStream, bound_repos).calculate_and_import
      end

      def import_applicability(partial = false)
        import_module_stream_applicability(partial)
        import_errata_applicability(partial)
        import_rpm_applicability(partial)
        update_applicability_counts
      end

      def update_applicability_counts
        self.assign_attributes(
            :installable_security_errata_count => self.installable_errata.security.count,
            :installable_bugfix_errata_count => self.installable_errata.bugfix.count,
            :installable_enhancement_errata_count => self.installable_errata.enhancement.count,
            :applicable_rpm_count => self.content_facet_applicable_rpms.count,
            :upgradable_rpm_count => self.installable_rpms.count,
            :applicable_module_stream_count => self.content_facet_applicable_module_streams.count,
            :upgradable_module_stream_count => self.installable_module_streams.count
        )
        self.save!(:validate => false)
      end

      def import_rpm_applicability(partial)
        ApplicableContentHelper.new(Rpm, self).import(partial)
      end

      def import_errata_applicability(partial)
        ApplicableContentHelper.new(Erratum, self).import(partial)
        self.update_errata_status
      end

      def import_module_stream_applicability(partial)
        ApplicableContentHelper.new(ModuleStream, self).import(partial)
      end

      def self.in_content_view_version_environments(version_environments)
        #takes a structure of [{:content_view_version => ContentViewVersion, :environments => [KTEnvironment]}]
        queries = version_environments.map do |version_environment|
          version = version_environment[:content_view_version]
          env_ids = version_environment[:environments].map(&:id)
          "(#{table_name}.content_view_id = #{version.content_view_id} AND #{table_name}.lifecycle_environment_id IN (#{env_ids.join(',')}))"
        end
        where(queries.join(" OR "))
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

      def self.joins_installable_rpms
        joins_installable_relation(Katello::Rpm, Katello::ContentFacetApplicableRpm)
      end

      def content_view_version
        content_view.version(lifecycle_environment)
      end

      def available_releases
        self.content_view.version(self.lifecycle_environment).available_releases
      end

      def katello_agent_installed?
        self.host.installed_packages.where("#{Katello::InstalledPackage.table_name}.name" => 'katello-agent').any?
      end

      def tracer_installed?
        self.host.installed_packages.where("#{Katello::InstalledPackage.table_name}.name" => 'katello-host-tools-tracer').any?
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

      class Jail < ::Safemode::Jail
        allow :applicable_module_stream_count, :applicable_rpm_count, :content_source, :content_source_id, :content_source_name, :content_view_id,
              :content_view_name, :errata_counts, :id, :kickstart_repository, :kickstart_repository_id, :kickstart_repository_name,
              :lifecycle_environment_id, :lifecycle_environment_name, :upgradable_module_stream_count, :upgradable_rpm_count, :uuid
      end
    end
  end
end
