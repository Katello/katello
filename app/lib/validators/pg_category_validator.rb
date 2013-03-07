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
  class PgCategoryValidator < ActiveModel::Validator
    def validate(record)
      env = record.system_template.environment
      if env.package_group_categories({'name' => record.name}).length == 0
        record.errors[:base] <<  _("Package group category '%{group}' not found in the %{env} environment") % {:group => record.name, :env => env.name}
      end
    end
  end
end