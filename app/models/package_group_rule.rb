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

class PackageGroupRule < FilterRule
  validates_with Validators::PackageGroupRuleParamsValidator, :attributes => :parameters
  def params_format
    {:units => [[:name]]}
  end

  def generate_clauses(repo)
    ids = parameters[:units].collect do |unit|
      #{'name' => {"$regex" => unit[:name]}}
      unless unit[:name].blank?
        PackageGroup.search(unit[:name], 0, 0, [repo.pulp_id]).collect(&:package_group_id)
      end
    end.compact.flatten
    {"id" => {"$in" => ids}}
  end
end
