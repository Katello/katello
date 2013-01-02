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
  class DistributionValidator < ActiveModel::Validator
    def validate(record)
      id = record.distribution_pulp_id
      env = record.system_template.environment
      cnt = env.get_distribution(id).length
      record.errors[:base] << _("Distribution '%{id}' not found in the '%{name}' environment") % {:id => id, :name => env.name} if cnt == 0
    end
  end
end