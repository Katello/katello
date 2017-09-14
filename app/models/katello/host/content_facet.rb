module Katello
  module Host
    class ContentFacet < Katello::Model
      self.table_name = 'katello_content_facets'
      include Facets::Base

      belongs_to :kickstart_repository, :class_name => "::Katello::Repository", :foreign_key => :kickstart_repository_id, :inverse_of => :kickstart_content_facets
      belongs_to :content_view, :inverse_of => :content_facets, :class_name => "Katello::ContentView"
      belongs_to :lifecycle_environment, :inverse_of => :content_facets, :class_name => "Katello::KTEnvironment"
      belongs_to :content_source, :class_name => "::SmartProxy", :foreign_key => :content_source_id, :inverse_of => :content_facets

      has_many :applicable_errata, :through => :content_facet_errata, :class_name => "Katello::Erratum", :source => :erratum
      has_many :content_facet_errata, :class_name => "Katello::ContentFacetErratum", :dependent => :destroy, :inverse_of => :content_facet

      has_many :bound_repositories, :through => :content_facet_repositories, :class_name => "Katello::Repository", :source => :repository
      has_many :content_facet_repositories, :class_name => "Katello::ContentFacetRepository", :dependent => :destroy, :inverse_of => :content_facet

      has_many :applicable_rpms, :through => :content_facet_applicable_rpms, :class_name => "Katello::Rpm", :source => :rpm
      has_many :content_facet_applicable_rpms, :class_name => "Katello::ContentFacetApplicableRpm", :dependent => :destroy, :inverse_of => :content_facet

      validates :content_view, :presence => true, :allow_blank => false
      validates :lifecycle_environment, :presence => true, :allow_blank => false
      validates :host, :presence => true, :allow_blank => false
      validates_with Validators::ContentViewEnvironmentValidator

      def update_repositories_by_paths(paths)
        paths = paths.map { |path| path.gsub('/pulp/repos/', '') }
        repos = Repository.where(:relative_path => paths)

        missing = paths - repos.pluck(:relative_path)
        missing.each do |repo_path|
          Rails.logger.warn("System #{self.host.name} (#{self.host.id}) requested binding to unknown repo #{repo_path}")
        end

        unless self.bound_repositories.sort == repos.sort
          self.bound_repositories = repos
          self.save!
          self.propagate_yum_repos
          ForemanTasks.async_task(Actions::Katello::Host::GenerateApplicability, [self.host])
        end
        self.bound_repositories.pluck(:relative_path)
      end

      def propagate_yum_repos
        pulp_ids = self.bound_repositories.includes(:library_instance).map { |repo| repo.library_instance.try(:pulp_id) || repo.pulp_id }
        Katello::Pulp::Consumer.new(self.uuid).bind_yum_repositories(pulp_ids)
      end

      def installable_errata(env = nil, content_view = nil)
        repos = if env && content_view
                  Katello::Repository.in_environment(env).in_content_views([content_view])
                else
                  self.bound_repositories.pluck(:id)
                end
        self.applicable_errata.in_repositories(repos).uniq
      end

      def installable_rpms(env = nil, content_view = nil)
        repos = if env && content_view
                  Katello::Repository.in_environment(env).in_content_views([content_view])
                else
                  self.bound_repositories.pluck(:id)
                end
        self.applicable_rpms.in_repositories(repos).uniq
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

      def import_applicability(partial = false)
        import_errata_applicability(partial)
        import_rpm_applicability(partial)
        update_applicability_counts
      end

      def update_applicability_counts
        self.update_attributes!(
            :installable_security_errata_count => self.installable_errata.security.count,
            :installable_bugfix_errata_count => self.installable_errata.bugfix.count,
            :installable_enhancement_errata_count => self.installable_errata.enhancement.count,
            :applicable_rpm_count => self.applicable_rpms.count,
            :upgradable_rpm_count => self.installable_rpms.count
        )
      end

      def import_rpm_applicability(partial)
        to_add, to_remove = applicable_rpm_differences(partial)
        Katello::ContentFacetApplicableRpm.where(:content_facet_id => self.id).delete_all unless partial
        ActiveRecord::Base.transaction do
          insert_rpm_applicability(to_add) unless to_add.blank?
          remove_rpm_applicability(to_remove) unless to_remove.blank?
        end
      end

      def import_errata_applicability(partial)
        to_add, to_remove = applicable_errata_differences(partial)
        Katello::ContentFacetErratum.where(:content_facet_id => self.id).delete_all unless partial
        ActiveRecord::Base.transaction do
          insert_errata_applicability(to_add) unless to_add.blank?
          remove_errata_applicability(to_remove) unless to_remove.blank?
        end
        self.update_errata_status
      end

      def applicable_errata_differences(partial)
        errata_uuids = ::Katello::Pulp::Consumer.new(self.uuid).applicable_errata_ids
        if partial
          consumer_uuids = applicable_errata.pluck("#{Erratum.table_name}.uuid")
          to_remove = consumer_uuids - errata_uuids
          to_add = errata_uuids - consumer_uuids
        else
          to_add = errata_uuids
          to_remove = nil
        end
        [to_add, to_remove]
      end

      def applicable_rpm_differences(partial)
        rpm_uuids = ::Katello::Pulp::Consumer.new(self.uuid).applicable_rpm_ids
        if partial
          consumer_uuids = applicable_rpms.pluck("#{Rpm.table_name}.uuid")
          to_remove = consumer_uuids - rpm_uuids
          to_add = rpm_uuids - consumer_uuids
        else
          to_add = rpm_uuids
          to_remove = nil
        end
        [to_add, to_remove]
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

      def self.with_non_installable_errata(errata)
        subquery = Katello::Erratum.select("#{Katello::Erratum.table_name}.id").ids_installable_for_hosts
        .where("#{Katello::ContentFacetRepository.table_name}.content_facet_id = #{Katello::Host::ContentFacet.table_name}.id").to_sql
        self.joins(:applicable_errata).where("#{Katello::Erratum.table_name}.id" => errata).where("#{Katello::Erratum.table_name}.id NOT IN (#{subquery})").uniq
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

      private

      def insert_rpm_applicability(uuids)
        applicable_rpm_ids = ::Katello::Rpm.where(:uuid => uuids).pluck(:id)
        unless applicable_rpm_ids.empty?
          inserts = applicable_rpm_ids.map { |erratum_id| "(#{erratum_id.to_i}, #{self.id.to_i})" }
          sql = "INSERT INTO #{Katello::ContentFacetApplicableRpm.table_name} (rpm_id, content_facet_id) VALUES #{inserts.join(', ')}"
          ActiveRecord::Base.connection.execute(sql)
        end
      end

      def remove_rpm_applicability(uuids)
        applicable_rpm_ids = ::Katello::Rpm.where(:uuid => uuids).pluck(:id)
        Katello::ContentFacetApplicableRpm.where(:content_facet_id => self.id, :rpm_id => applicable_rpm_ids).delete_all
      end

      def insert_errata_applicability(uuids)
        applicable_errata_ids = ::Katello::Erratum.where(:uuid => uuids).pluck(:id)
        unless applicable_errata_ids.empty?
          inserts = applicable_errata_ids.map { |erratum_id| "(#{erratum_id.to_i}, #{self.id.to_i})" }
          sql = "INSERT INTO #{Katello::ContentFacetErratum.table_name} (erratum_id, content_facet_id) VALUES #{inserts.join(', ')}"
          ActiveRecord::Base.connection.execute(sql)
        end
      end

      def remove_errata_applicability(uuids)
        applicable_errata_ids = ::Katello::Erratum.where(:uuid => uuids).pluck(:id)
        Katello::ContentFacetErratum.where(:content_facet_id => self.id, :erratum_id => applicable_errata_ids).delete_all
      end
    end
  end
end
