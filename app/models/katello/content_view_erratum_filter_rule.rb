#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  class ContentViewErratumFilterRule < Katello::Model
    self.include_root_in_json = false

    include Glue::ElasticSearch::ContentViewErratumFilterRule if Katello.config.use_elasticsearch

    belongs_to :filter,
               :class_name => "Katello::ContentViewErratumFilter",
               :inverse_of => :erratum_rules,
               :foreign_key => :content_view_filter_id

    serialize :types, Array

    validates_lengths_from_database
    validates :errata_id, :uniqueness => { :scope => :content_view_filter_id }, :allow_blank => true
    validates_with Validators::ContentViewErratumFilterRuleValidator

    def filter_has_date_or_type_rule?
      filter.erratum_rules.any?{ |rule| rule.start_date || rule.end_date || !rule.types.blank? }
    end
  end
end
