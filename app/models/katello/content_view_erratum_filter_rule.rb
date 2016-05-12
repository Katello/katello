module Katello
  class ContentViewErratumFilterRule < Katello::Model
    self.include_root_in_json = false

    ISSUED = "issued".freeze
    UPDATED = "updated".freeze
    DATE_TYPES = [ISSUED, UPDATED].freeze

    belongs_to :filter,
               :class_name => "Katello::ContentViewErratumFilter",
               :inverse_of => :erratum_rules,
               :foreign_key => :content_view_filter_id

    serialize :types, Array

    validates_lengths_from_database
    validates :errata_id, :uniqueness => { :scope => :content_view_filter_id }, :allow_blank => true
    validates_with Validators::ContentViewErratumFilterRuleValidator

    validates :date_type,
      :if => proc { |o| o.start_date || o.end_date },
      :inclusion => {
        :in => DATE_TYPES,
        :allow_blank => false,
        :message => (_("must be one of the following: %s") % DATE_TYPES.join(', '))
      }

    def filter_has_date_or_type_rule?
      filter.erratum_rules.any? { |rule| rule.start_date || rule.end_date || !rule.types.blank? }
    end

    def pulp_date_type
      self.date_type == ISSUED ? "issued" : "updated"
    end
  end
end
