module Katello
  class ContentViewErratumFilter < ContentViewFilter
    CONTENT_TYPE = Erratum::CONTENT_TYPE

    ERRATA_TYPES = { 'bugfix' => _('Bug Fix'),
                     'enhancement' => _('Enhancement'),
                     'security' => _('Security') }.with_indifferent_access

    has_many :erratum_rules, :dependent => :destroy, :foreign_key => :content_view_filter_id,
                             :class_name => "Katello::ContentViewErratumFilterRule"

    validates_lengths_from_database

    def generate_clauses(_repo)
      return if erratum_rules.blank?

      if filter_by_id?
        errata_ids = erratum_rules.map(&:errata_id)
        errata_in(errata_ids) unless errata_ids.empty?
      else # filtering by date/type
        clauses = []
        clauses << errata_from
        clauses << errata_to
        clauses << types_clause
        clauses.compact.inject(&:and)
      end
    end

    def content_unit_pulp_ids(repo, additional_included_errata = [])
      return [] if erratum_rules.blank?

      if filter_by_id?
        errata_ids = erratum_rules.map(&:errata_id)
        # additional_included_errata and inclusion filters don't work together (since it only applies when excluding)
        if self.inclusion?
          errata_pulp_ids = errata_package_pulp_ids_from_errata_ids(repo, errata_ids, [])
          errata_pulp_ids += errata_module_stream_pulp_ids_from_errata_ids(repo, errata_ids, [])
        else
          errata_pulp_ids = errata_package_pulp_ids_from_errata_ids(repo, errata_ids, additional_included_errata)
          errata_pulp_ids += errata_module_stream_pulp_ids_from_errata_ids(repo, errata_ids, additional_included_errata)
        end
      else
        clauses = []
        clauses << errata_from
        clauses << errata_to
        clauses << types_clause
        if self.inclusion?
          package_filenames = Erratum.list_filenames_by_clauses(repo, clauses.compact, [])
          errata_pulp_ids = errata_package_pulp_ids_from_package_filenames(repo, package_filenames)
          errata_pulp_ids += errata_module_stream_pulp_ids_from_clauses(repo, clauses.compact, [])
        else
          package_filenames = Erratum.list_filenames_by_clauses(repo, clauses.compact, additional_included_errata)
          errata_pulp_ids = errata_package_pulp_ids_from_package_filenames(repo, package_filenames)
          errata_pulp_ids += errata_module_stream_pulp_ids_from_clauses(repo, clauses.compact, additional_included_errata)
        end
      end

      errata_pulp_ids
    end

    private

    def rpms_by_filename(repo, package_filenames)
      query_params = package_filenames.map { |filename| "%#{filename}" }
      repo.rpms.where("filename ILIKE ANY ( array[?] )", query_params)
    end

    def errata_module_stream_pulp_ids_from_clauses(repo, clauses, additional_included_errata)
      module_streams = Erratum.list_modular_streams_by_clauses(repo, clauses, additional_included_errata)
      module_streams.pluck(:pulp_id)
    end

    def errata_package_pulp_ids_from_package_filenames(repo, package_filenames)
      rpms_by_filename(repo, package_filenames).pluck(:pulp_id)
    end

    def errata_module_stream_pulp_ids_from_errata_ids(repo, errata_ids, additional_included_errata)
      module_streams = Katello::Erratum.where(:errata_id => errata_ids).map(&:module_streams).compact.flatten -
        Katello::Erratum.where(:errata_id => additional_included_errata.pluck(:errata_id)).map(&:module_streams).compact.flatten
      ModuleStream.joins(:repository_module_streams).
        where(:id => module_streams.pluck(:id), "#{RepositoryModuleStream.table_name}.repository_id" => repo.id).pluck(:pulp_id)
    end

    def errata_package_pulp_ids_from_errata_ids(repo, errata_ids, additional_included_errata)
      package_filenames = Katello::ErratumPackage.joins(:erratum).where("#{Erratum.table_name}.errata_id" => errata_ids).pluck(:filename) -
        Katello::ErratumPackage.joins(:erratum).where("#{Erratum.table_name}.errata_id" => additional_included_errata.pluck(:errata_id)).pluck(:filename)
      rpms_by_filename(repo, package_filenames).pluck(:pulp_id)
    end

    def erratum_arel
      ::Katello::Erratum.arel_table
    end

    def types_clause
      types = erratum_rules.first.types
      return if types.blank?
      errata_types_in(types)
    end

    def filter_by_id?
      !erratum_rules.blank? && !erratum_rules.first.errata_id.blank?
    end

    def errata_types_in(types)
      erratum_arel[:errata_type].in(types)
    end

    def errata_in(ids)
      erratum_arel[:errata_id].in(ids)
    end

    def errata_from
      start_date = erratum_rules.first.start_date
      return if start_date.blank?
      date_type = erratum_rules.first.pulp_date_type.to_sym

      # "katello_errata"."issued" >= '2017-11-23'
      erratum_arel[date_type].gteq(start_date)
    end

    def errata_to
      end_date = erratum_rules.first.end_date
      return if end_date.blank?
      date_type = erratum_rules.first.pulp_date_type.to_sym

      # "katello_errata"."issued" <= '2017-11-23'
      erratum_arel[date_type].lteq(end_date)
    end
  end
end
