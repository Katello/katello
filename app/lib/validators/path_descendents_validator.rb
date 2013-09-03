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
  class PathDescendentsValidator < ActiveModel::Validator
    def validate(record)
      #need to ensure that
      #environment is not duplicated in its path
      # We do not want circular dependencies
      return if record.prior.nil?
      record.errors[:prior] << _(" environment cannot be set to an environment already on its path") if is_duplicate? record.prior
    end

    def is_duplicate?(record)
      s = record.successor
      ret = [record.id]
      until s.nil?
        return true if ret.include? s.id
        ret << s.id
        s = s.successor
      end
      false
    end
  end
end