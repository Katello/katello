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
class ContentViewErratumFilter < ContentViewFilter
  use_index_of ContentViewFilter if Katello.config.use_elasticsearch

  CONTENT_TYPE = Errata::CONTENT_TYPE

  ERRATA_TYPES = { 'bugfix' => _('Bug Fix'),
                   'enhancement' => _('Enhancement'),
                   'security' => _('Security') }.with_indifferent_access

  has_many :erratum_rules, :dependent => :destroy, :foreign_key => :content_view_filter_id,
           :class_name => "Katello::ContentViewErratumFilterRule"

  def generate_clauses(repo)

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
        date_range["$gte"] = start_date.to_time.as_json unless start_date.blank?
        date_range["$lte"] = end_date.to_time.as_json unless end_date.blank?
        rule_clauses << { "issued" => date_range }
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
