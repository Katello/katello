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

class SystemTemplatePackage < ActiveRecord::Base

  belongs_to :system_template, :inverse_of => :packages
  validates_with Validators::PackageUniquenessValidator
  validates_with Validators::PackageValidator

  def is_nvr?
    not (self.package_name.nil? or self.version.nil? or self.release.nil?)
  end

  def nvrea
    if self.is_nvr?
      attrs = self.attributes.with_indifferent_access
      attrs[:name] = attrs[:package_name]
      Util::Package.build_nvrea attrs
    else
      self.package_name
    end
  end

end
