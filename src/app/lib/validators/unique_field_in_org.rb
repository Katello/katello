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

# For models that belongs_to :environment that wish to check a fields uniqueness across the org
# eg. validates_with Validators::UniqueFieldInOrg, :attributes => :name
module Validators
  class UniqueFieldInOrg < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value
        others = record.class.where(attribute => value).joins(:environment).where("environments.organization_id" => record.environment.organization_id)
        others.where("id != ?", record.id) if record.id
        record.errors[attribute] << N_("already taken") if others.any?
      end
    end
  end
end
