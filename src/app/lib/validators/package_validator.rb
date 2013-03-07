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

module Validators
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

      record.errors[:base] <<  _("Package '%{package}' not found in the %{env} environment") % {:package => name, :env => env.name} if cnt == 0
    end
  end
end