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
  class SerializedParamsValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value
        diff = Util::Support.diff_hash_params(record.params_format, value)
        unless diff.empty?
          msg = _("The parameters are in an invalid format. Please check the following attribute '%s'") % diff.inspect
          record.errors.add(attribute, msg)
        end
      end
    end
  end
end