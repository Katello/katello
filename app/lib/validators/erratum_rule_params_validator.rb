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
  class ErratumRuleParamsValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value
        if value.has_key?(:date_range)
          date_range = value[:date_range]
          start_date_int = date_range[:start]
          end_date_int = date_range[:end]

          if start_date_int && !(start_date_int.is_a?(Fixnum))
            record.errors.add(attribute, _("The erratum rule start date is in an invalid format or type."))
          end
          if end_date_int && !(end_date_int.is_a?(Fixnum))
            record.errors.add(attribute, _("The erratum rule end date is in an invalid format or type."))
          end

          if start_date_int && end_date_int && !(start_date_int <= end_date_int)
            record.errors.add(attribute, _("Invalid date range. The erratum rule start date must come before the end date"))
          end
        end

        if value.has_key?(:errata_type)
          errata_type = value[:errata_type]
          if errata_type.is_a?(Array)
            invalid_types = errata_type.collect(&:to_s) - ErratumRule::ERRATA_TYPES.keys
            unless invalid_types.empty?
              record.errors.add(attribute,
                   _("Invalid erratum types %{invalid_types} provided. Erratum type can be any of %{valid_types}") %
                                    { :invalid_types => invalid_types.join(","),
                                      :valid_types => ErratumRule::ERRATA_TYPES.keys.join(",")})
            end
          else
            record.errors.add(attribute, _("The erratum type must be an array. Invalid value provided"))
          end
        end
      end
    end
  end
end