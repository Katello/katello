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

  # Returns a set of Pulp/MongoDB conditions to filter out packages in the
  # repo repository that match parameters
  #
  # @param repo [Repository] a repository containing packages to filter
  # @return [Array] an array of hashes with MongoDB conditions
  def generate_clauses(repo)
    parameters[:units].each_with_object([]) do |unit, rule_clauses|
      next if unit[:name].blank?
      clauses = []

      results = Package.search(unit[:name], 0, repo.package_count, [repo.pulp_id],
                      [:nvrea_sort, "ASC"], :all, 'name' ).collect(&:filename).compact
      next if results.empty?

      clauses << {'filename' => {"$in" => results}}

      if (version_clause = generate_version_clause(repo, unit))
        clauses << version_clause
      end

      rule_clauses << (clauses.length == 1 ? clauses.first : {'$and' => clauses})
    end
  end

  protected

  def generate_version_clause(repo, unit)
    return unless unit.keys.any? { |key| [:version, :min_version, :max_version].include?(key.to_sym) }

    if unit.has_key?(:version)
      filter = Util::Package.version_eq_filter(unit[:version])
    else
      filter = Util::Package.version_filter(unit[:min_version], unit[:max_version])
    end

    results = Package.search(unit[:name], 0, repo.package_count, [repo.pulp_id],
        [:nvrea_sort, "ASC"], :all, 'name', filter).map(&:filename).compact

    {'filename' => {"$in" => results}}
  end

end