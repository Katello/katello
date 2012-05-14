#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class PackageUniquenessValidator < ActiveModel::Validator
  def validate(record)
    duplicate_ids = SystemTemplatePackage.where(:system_template_id => record.system_template_id, :package_name => record.package_name, :version => record.version, :release => record.release, :epoch => record.epoch, :arch => record.arch).all.map {|p| p.id}
    duplicate_ids -= [record.id]
    record.errors[:base] << _("Package '%s' is already present in the template") % record.nvrea if duplicate_ids.count > 0
  end
end

class PackageValidator < ActiveModel::Validator
  def validate(record)
    env = record.system_template.environment
    if record.is_nvr?
      cnt = env.find_packages_by_nvre(record.package_name, record.version, record.release, record.epoch).length
      name = record.nvrea
    else
      cnt = env.find_packages_by_name(record.package_name).length
      name = record.package_name
    end

    record.errors[:base] <<  _("Package '%s' not found in the %s environment") % [name, env.name] if cnt == 0
  end
end

class SystemTemplatePackage < ActiveRecord::Base
  include Authorization

  belongs_to :system_template, :inverse_of => :packages
  validates_with PackageUniquenessValidator
  validates_with PackageValidator

  def is_nvr?
    not (self.package_name.nil? or self.version.nil? or self.release.nil?)
  end

  def nvrea
    if self.is_nvr?
      attrs = self.attributes.with_indifferent_access
      attrs[:name] = attrs[:package_name]
      Katello::PackageUtils.build_nvrea attrs
    else
      self.package_name
    end
  end

end
