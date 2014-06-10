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
class ContentViewPackageFilter < ContentViewFilter
  use_index_of ContentViewFilter if Katello.config.use_elasticsearch

  CONTENT_TYPE = Package::CONTENT_TYPE

  has_many :package_rules, :dependent => :destroy, :foreign_key => :content_view_filter_id,
           :class_name => "Katello::ContentViewPackageFilterRule"

  # Returns a set of Pulp/MongoDB conditions to filter out packages in the
  # repo repository that match parameters
  #
  # @param repo [Repository] a repository containing packages to filter
  # @return [Array] an array of hashes with MongoDB conditions
  def generate_clauses(repo)
    package_filenames = package_rules.reject{ |rule| rule.name.blank? }.flat_map do |rule|
      filter = version_filter(rule)
      Package.legacy_search(rule.name, 0, repo.package_count, [repo.pulp_id], [:nvrea_sort, "asc"],
                     :all, 'name', filter).map(&:filename).compact
    end

    if self.original_packages
      package_filenames.concat(repo.packages_without_errata.map(&:filename))
    end

    { 'filename' => { "$in" => package_filenames } } unless package_filenames.empty?
  end

  def original_packages=(value)
    write_attribute(:original_packages, value)
  end

  protected

  def version_filter(rule)
    if !rule.version.blank?
      Util::Package.version_eq_filter(rule.version)
    elsif !rule.min_version.blank? || !rule.max_version.blank?
      Util::Package.version_filter(rule.min_version, rule.max_version)
    end
  end

end
end
