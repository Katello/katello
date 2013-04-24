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

module Validators
  class PackageRuleParamsValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      ver_msg = _("Invalid rule combination specified, '%s' and '%s' or '%s' cannot be specified in the same tuple") %
                                                                              ["version", "min_version", "max_version"]
      if value
        unless value[:units].blank?
          unless value[:units].is_a?(Array)
            record.errors.add(attribute, _("Invalid package rule specified. Units must be an array."))
          else
            value[:units].each do |unit|
              unless unit.has_key?(:name)
                record.errors.add(attribute, _("Invalid package rule specified. Missing package 'name'."))
                break
              end
              if unit.has_key?(:version) && (unit.has_key?(:min_version) || unit.has_key?(:max_version))
                record.errors.add(attribute, ver_msg)
              end

            end
          end
        end
       end
    end
  end
end