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

class PackageRule < FilterRule
  def generate_clauses(repo)
    parameters[:units].collect do |unit|
      rule_clauses = []
      if unit[:name] && !unit[:name].blank?
        results = Package.search(unit[:name], 0, 0, [repo.pulp_id],
                        [:nvrea_sort, "ASC"], :all, 'name' ).collect(&:filename)
        unless results.empty?
          rule_clauses << {'filename' => {"$in" => results}}
        end
      end

      if unit.has_key? :version
        rule_clauses << {'version' => unit[:version] }
      else
        vr = {}
        vr["$gte"] = unit[:min_version] if unit.has_key? :min_version
        vr["$lte"] = unit[:max_version] if unit.has_key? :max_version
        rule_clauses << {'version' => vr } unless vr.empty?
      end
      case rule_clauses.size
        when 1
          rule_clauses.first
        when 2
          {'$and' => rule_clauses}
        else
          #ignore
      end
    end.compact if parameters.has_key?(:units)
  end
end
