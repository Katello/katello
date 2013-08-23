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

class PuppetModuleRule < FilterRule
  validates_with Validators::RuleParamsValidator, :attributes => :parameters
  validates_with Validators::RuleVersionValidator, :attributes => :parameters

  def params_format
    {:units => [[:name, :author, :version, :min_version, :max_version]]}
  end

  # Returns a set of Pulp/MongoDB conditions to filter out packages in the
  # repo repository that match parameters
  #
  # @param repo [Repository] a repository containing packages to filter
  # @return [Array] an array of hashes with MongoDB conditions
  def generate_clauses(repo)
    parameters[:units].map do |unit|
      next if unit[:name].blank?

      filters = []
      filters << version_filter(unit)
      filters << author_filter(unit)
      filters.compact!

      results = PuppetModule.search(unit[:name], :page_size => repo.puppet_module_count, :repoids => [repo.pulp_id],
                                    :filters => filters).map(&:_id).compact
      next if results.empty?

      {'_id' => {"$in" => results}}
    end
  end

  protected

  def version_filter(unit)
    if unit.has_key?(:version)
      {:term => {:version => unit[:version]}}
    elsif unit.has_key?(:min_version) || unit.has_key?(:max_version)
      range = {}
      range[:gt] = sortable_version(unit[:min_version]) if unit[:min_version]
      range[:lt] = sortable_version(unit[:max_version]) if unit[:max_version]
      {:range => {:sortable_version => range}}
    else
      nil
    end
  end

  def author_filter(unit)
    if unit.has_key?(:author) && unit[:author].present?
      {:term => {:author => unit[:author]}}
    else
      nil
    end
  end

  def sortable_version(version)
    Util::Package.sortable_version(version)
  end
end