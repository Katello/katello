#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class ErratumRule < FilterRule
  def generate_clauses(repo)
    rule_clauses = []
    if parameters.has_key? :units
      # TODO: WIll add this when we have a proper analyzer for
      # errata_id..
      # ids = parameters[:units].collect do |unit|
      #   if unit[:id] && !unit[:id].blank?
      #     results = Errata.search(unit[:id], 0, 0, [repo.pulp_id], {},
      #                         [:errata_id_sort, "DESC"],'errata_id').collect(&:errata_id)
      #   end
      # end.compact.flatten
      ids = parameters[:units].collect do |unit|
        unit[:id]
      end.compact

      {"id" => {"$in" => ids}}  unless ids.empty?
    else
      if parameters.has_key? :date_range
        date_range = parameters[:date_range]
        dr = {}
        dr["$gte"] = convert_date(date_range[:start]).as_json if date_range.has_key? :start
        dr["$lte"] = convert_date(date_range[:end]).as_json if date_range.has_key? :end
        rule_clauses << {"issued" => dr}
      end
      if parameters.has_key?(:errata_type) && !parameters[:errata_type].empty?
          # {"type": {"$in": ["security", "enhancement", "bugfix"]}
        rule_clauses << {"type" => {"$in" => parameters[:errata_type]}}
      end

      if parameters.has_key?(:severity) && !parameters[:severity].empty?
          # {"severity": {"$in": ["low", "moderate", "important", "critical"]}
        rule_clauses << {"severity" => {"$in" => parameters[:severity]}}
      end

      case rule_clauses.size
        when 0
          return
        when 1
          return rule_clauses.first
        else
          return {'$and' => rule_clauses}
      end
    end
  end

  #convert date, time from UI to object
  def convert_date(date)
    return nil if date.blank?
    event = date +  ' '  + DateTime.now.zone
    DateTime.strptime(event, "%m/%d/%Y %:z")
  rescue ArgumentError
    raise _("Invalid date or time format")
  end
end
