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
  class ContentViewPackageGroupFilter < ContentViewFilter
    use_index_of ContentViewFilter if Katello.config.use_elasticsearch

    CONTENT_TYPE = PackageGroup::CONTENT_TYPE

    has_many :package_group_rules, :dependent => :destroy, :foreign_key => :content_view_filter_id,
                                   :class_name => "Katello::ContentViewPackageGroupFilterRule"
    validates_lengths_from_database

    def generate_clauses(repo)
      package_group_ids = package_group_rules.reject { |rule| rule.uuid.blank? }.flat_map do |rule|
        PackageGroup.legacy_search(rule.uuid, 0, 0, [repo.pulp_id], [:name_sort, "asc"], 'id').map(&:package_group_id).compact
      end
      { "id" => { "$in" => package_group_ids } } unless package_group_ids.empty?
    end
  end
end
