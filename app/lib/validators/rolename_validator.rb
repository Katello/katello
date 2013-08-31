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
  class RolenameValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      # If role is self-role, no need to re-validate the rolename, since it is based on the username.
      if value && !record.is_a?(UserOwnRole)
         # max length is 20 more than the username because we add 20 random characters
         # on the end for the self role
        record.errors[attribute] << N_("cannot contain characters >, <, or /") if value =~ /<|>|\//
        KatelloNameFormatValidator.validate_length(record, attribute, value, 148, 3)
      end
    end
  end
end
