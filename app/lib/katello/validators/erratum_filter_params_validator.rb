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
  class ErratumFilterParamsValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value
        if value.key?("units") && (value.key?("date_range") ||
                                   value.key?("errata_type"))
          record.errors.add(attribute, _("Errata filters cannot contain both id and date_range/errata_type criteria."))
        end
        if value.key?(:date_range)
          _check_date_range(record, attribute, value)
        end

        if value.key?(:errata_type)
          _check_errata_type(record, attribute, value)
        end
      end
    end

    def _check_errata_type(record, attribute, value)
      errata_type = value[:errata_type]
      if errata_type.is_a?(Array)
        invalid_types = errata_type.collect(&:to_s) - ErratumFilter::ERRATA_TYPES.keys
        unless invalid_types.empty?
          record.errors.add(attribute,
                            _("Invalid erratum types %{invalid_types} provided. Erratum type can be any of %{valid_types}") %
                            { :invalid_types => invalid_types.join(","),
                              :valid_types => ErratumFilter::ERRATA_TYPES.keys.join(",")})
        end
      else
        record.errors.add(attribute, _("The erratum type must be an array. Invalid value provided"))
      end
    end

    def _check_date_range(record, attribute, value)
      date_range = value[:date_range]
      start_date_int = date_range[:start].to_time.to_i if date_range.has_key?(:start)
      end_date_int = date_range[:end].to_time.to_i if date_range.has_key?(:end)

      if start_date_int && (!(start_date_int.is_a?(Fixnum)) || !(date_range[:start].is_a?(String)))
        record.errors.add(attribute, _("The erratum filter parameter start date is in an invalid format or type."))
      end
      if end_date_int && (!(end_date_int.is_a?(Fixnum)) || !(date_range[:end].is_a?(String)))
        record.errors.add(attribute, _("The erratum filter parameter end date is in an invalid format or type."))
      end

      if start_date_int && end_date_int && !(start_date_int <= end_date_int)
        record.errors.add(attribute, _("Invalid date range. The erratum filter parameter start date must come before the end date"))
      end
    end
  end
end
end
