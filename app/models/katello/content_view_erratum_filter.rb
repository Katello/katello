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
        return { "id" => { "$in" => errata_ids } } unless errata_ids.empty?

      else # filtering by date/type
        rule_clauses = []
        start_date = erratum_rules.first.start_date
        end_date = erratum_rules.first.end_date
        types = erratum_rules.first.types

        unless start_date.blank? && end_date.blank?
          date_range = {}
          date_range["$gte"] = start_date.to_time.utc.as_json unless start_date.blank?
          date_range["$lte"] = end_date.to_time.utc.as_json unless end_date.blank?
          rule_clauses << { erratum_rules.first.pulp_date_type => date_range }
        end
        unless types.blank?
          # {"type": {"$in": ["security", "enhancement", "bugfix"]}
          rule_clauses << { "type" => { "$in" => types } }
        end

        # Currently, an errata filter that specifies a date/type, will only have
        # single rule; therefore, we can return from here.
        case rule_clauses.size
        when 0
          return
        when 1
          return rule_clauses.first
        else
          return { '$and' => rule_clauses }
        end
      end
    end

    def filter_by_id?
      !erratum_rules.blank? && !erratum_rules.first.errata_id.blank?
    end
  end
end
