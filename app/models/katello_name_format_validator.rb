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

class KatelloNameFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value
      record.errors[attribute] << N_("cannot contain characters other than alpha numerals, space,'_', '-'.") unless value =~ /\A[\w|\s|_|-]*\Z/
      NoTrailingSpaceValidator.validate_trailing_space(record, attribute, value)
      KatelloNameFormatValidator.validate_length(record, attribute, value)
    else
      record.errors[attribute] << N_("can't be blank")
    end
  end

  def self.validate_length(record, attribute, value, max_length = 128, min_length = 2)
    if value
      record.errors[attribute] << N_("cannot contain more than #{max_length} characters") unless value.length <= max_length
      record.errors[attribute] << N_("must contain at least #{min_length} characters") unless value.length >= min_length
    end
  end
end