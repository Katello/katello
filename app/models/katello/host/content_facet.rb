module Katello
  module Host
    class ContentFacet < Katello::Model
      self.table_name = 'katello_content_facets'

      belongs_to :host, :inverse_of => :content_facet, :class_name => "::Host::Managed"
      belongs_to :content_view, :inverse_of => :content_facets, :class_name => "Katello::ContentView"
      belongs_to :lifecycle_environment, :inverse_of => :content_facets, :class_name => "Katello::KTEnvironment"

      has_many :applicable_errata, :through => :content_facet_errata, :class_name => "Katello::Erratum", :source => :erratum
      has_many :content_facet_errata, :class_name => "Katello::ContentFacetErratum", :dependent => :destroy, :inverse_of => :content_facet

      has_many :bound_repositories, :through => :content_facet_repositories, :class_name => "Katello::Repository", :source => :repository
      has_many :content_facet_repositories, :class_name => "Katello::ContentFacetRepository", :dependent => :destroy, :inverse_of => :content_facet

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

        self.bound_repositories = repos
        self.save!
        self.propagate_yum_repos
        ForemanTasks.async_task(Actions::Katello::Host::GenerateApplicability, [self.host])
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

      def import_applicability(partial = false)
        facet = self
        ::Katello::Util::Support.active_record_retry do
          ActiveRecord::Base.transaction do
            errata_uuids = ::Katello::Pulp::Consumer.new(self.uuid).applicable_errata_ids
            if partial
              consumer_uuids = applicable_errata.pluck("#{Erratum.table_name}.uuid")
              to_remove = consumer_uuids - errata_uuids
              to_add = errata_uuids - consumer_uuids
            else
              to_add = errata_uuids
              to_remove = nil
              Katello::ContentFacetErratum.where(:content_facet_id => facet.id).delete_all
            end
            insert_errata_applicability(to_add) unless to_add.blank?
            remove_errata_applicability(to_remove) unless to_remove.blank?
          end
        end
      end

      def self.with_non_installable_errata(errata)
        subquery = Katello::Erratum.select("#{Katello::Erratum.table_name}.id").installable_for_hosts
        .where("#{Katello::ContentFacetRepository.table_name}.content_facet_id = #{Katello::Host::ContentFacet.table_name}.id").to_sql
        self.joins(:applicable_errata).where("#{Katello::Erratum.table_name}.id" => errata).where("#{Katello::Erratum.table_name}.id NOT IN (#{subquery})").uniq
      end

      def self.with_applicable_errata(errata)
        self.joins(:applicable_errata).where("#{Katello::Erratum.table_name}.id" => errata)
      end

      def self.with_installable_errata(errata)
        non_installable = Katello::Host::ContentFacet.with_non_installable_errata(errata)
        subquery = Katello::Erratum.select("#{Katello::Erratum.table_name}.id").installable_for_hosts.
            where("#{Katello::ContentFacetRepository.table_name}.content_facet_id = #{Katello::Host::ContentFacet.table_name}.id")

        query = self.joins(:applicable_errata).where("#{Katello::Erratum.table_name}.id" => errata).where("#{Katello::Erratum.table_name}.id" => subquery)
        query = query.where.not("#{Katello::Host::ContentFacet.table_name}.id" => non_installable) unless non_installable.empty?
        query.uniq
      end

      def content_view_version
        content_view.version(lifecycle_environment)
      end

      def available_releases
        self.content_view.version(self.lifecycle_environment).available_releases
      end

      private

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
