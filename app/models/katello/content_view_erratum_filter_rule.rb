module Katello
  class ContentViewErratumFilterRule < Katello::Model
    include ::Katello::Concerns::ContentViewFilterRuleCommon

    before_create :default_types

    ISSUED = "issued".freeze
    UPDATED = "updated".freeze
    DATE_TYPES = [ISSUED, UPDATED].freeze

    belongs_to :filter,
               :class_name => "Katello::ContentViewErratumFilter",
               :inverse_of => :erratum_rules,
               :foreign_key => :content_view_filter_id

    serialize :types, Array

    validates :errata_id, :uniqueness => { :scope => :content_view_filter_id }, :allow_blank => true
    validates_with Validators::ContentViewErratumFilterRuleValidator

    validates :date_type,
      :if => proc { |o| o.start_date || o.end_date },
      :inclusion => {
        :in => DATE_TYPES,
        :allow_blank => false,
        :message => (_("must be one of the following: %s") % DATE_TYPES.join(', '))
      }

    def self.in_content_views(content_view_ids)
      joins('INNER JOIN katello_content_view_filters ON katello_content_view_erratum_filter_rules.content_view_filter_id = katello_content_view_filters.id').
        where("katello_content_view_filters.content_view_id IN (#{content_view_ids.join(',')})")
    end

    def filter_has_date_or_type_rule?
      filter.erratum_rules.any? { |rule| rule.start_date || rule.end_date || !rule.types.blank? }
    end

    def pulp_date_type
      self.date_type == ISSUED ? "issued" : "updated"
    end

    def default_types
      if errata_id.nil? && types.blank?
        self.types = ContentViewErratumFilter::ERRATA_TYPES.keys
      end
    end
  end
end
