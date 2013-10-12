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
module Validators
  class RuleVersionValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value && value[:units].present? && value[:units].is_a?(Array)
        value[:units].each do |unit|
          if unit.key?(:version) && (unit.key?(:min_version) || unit.key?(:max_version))
            ver_msg = _("Invalid rule combination specified, 'version'" +
                        " and 'min_version' or 'max_version' cannot be specified in the same tuple")

            record.errors.add(attribute, ver_msg)
          end
        end
      end
    end
  end
end
end
