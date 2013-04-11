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
  def params_format
    {:units => [[:name, :version, :min_version, :max_version]]}
  end

  # input -> {:units => [{:name => "pulp-admin-*", :version =>"2.0.8"},
  #             {:name => "pulp-rpm-*", :min_version =>"2.0.3", :max_version =>"2.0.9"}]}
  # output ->  [{"$and" => [{"filename"=>{"$in"=> ["pulp-admin-client"]}}, {"version" => "2.0.8"}]},
  #              {"$and" => [{"filename"=>{"$in"=> ["pulp-rpm-plugins", "pulp-rpm-admin"]}},
  #                         {"version" => {"$gte" => "2.0.3", "$lte" => "2.0.9"}}]}]
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
        version_clause = {}
        version_clause["$gte"] = unit[:min_version] if unit.has_key? :min_version
        version_clause["$lte"] = unit[:max_version] if unit.has_key? :max_version
        rule_clauses << {'version' => version_clause } unless version_clause.empty?
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