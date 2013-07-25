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
  validates_with Validators::PackageRuleParamsValidator, :attributes => :parameters

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
      unless unit[:name].blank?
        results = Package.search(unit[:name], 0, repo.package_count, [repo.pulp_id],
                        [:nvrea_sort, "ASC"], :all, 'name' ).collect(&:filename).compact
        rule_clauses << {'filename' => {"$in" => results}}
        unless results.empty?
          # now add version info
          rule_clauses << generate_version_clause(repo, unit)
        end
        rule_clauses.compact!
        if rule_clauses.size == 1
          rule_clauses.first
        else
          {'$and' => rule_clauses}
        end
      end
    end.compact
  end

  protected

  def generate_version_clause(repo, unit)
    if unit.has_key?(:version)
      {'version' => unit[:version] }
    elsif unit.has_key?(:min_version) || unit.has_key?(:max_version)
      filter = Util::Package.version_filter(unit[:min_version], unit[:max_version])
      results = Package.search(unit[:name], 0, repo.package_count, [repo.pulp_id],
          [:nvrea_sort, "ASC"], :all, 'name', filter).map(&:filename).compact

      {'filename' => {"$in" => results}}
    end
  end

end