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

module Katello
class PackageFilter < Filter
  use_index_of Filter if Katello.config.use_elasticsearch

  CONTENT_TYPE = Package::CONTENT_TYPE

  before_create :set_parameters

  validates_with Validators::FilterParamsValidator, :attributes => :parameters
  validates_with Validators::FilterVersionValidator, :attributes => :parameters

  def params_format
    { :units => [[:name, :version, :min_version, :max_version, :inclusion, :created_at]] }
  end

  # Returns a set of Pulp/MongoDB conditions to filter out packages in the
  # repo repository that match parameters
  #
  # @param repo [Repository] a repository containing packages to filter
  # @return [Array] an array of hashes with MongoDB conditions
  def generate_clauses(repo)
    pkg_filenames = parameters[:units].map do |unit|
      next if unit[:name].blank?

      filter = version_filter(unit)
      Package.search(unit[:name], 0, repo.package_count, [repo.pulp_id],
                      [:nvrea_sort, "ASC"], :all, 'name', filter).collect(&:filename).compact
    end
    pkg_filenames.flatten!
    pkg_filenames.compact!

    { 'filename' => { "$in" => pkg_filenames } } unless pkg_filenames.empty?
  end

  protected

  def version_filter(unit)
    if unit.key?(:version)
      Util::Package.version_eq_filter(unit[:version])
    elsif unit.key?(:min_version) || unit.key?(:max_version)
      Util::Package.version_filter(unit[:min_version], unit[:max_version])
    else
      nil
    end
  end

  private

  def set_parameters
    parameters[:units].each do |unit|
      unit[:created_at] = Time.zone.now
      unit[:inclusion] = false unless unit.has_key?(:inclusion)
    end if !parameters.blank? && parameters.has_key?(:units)
  end
end
end
