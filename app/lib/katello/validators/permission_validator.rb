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
    class PermissionValidator < ActiveModel::Validator
      def validate(record)
        if record.role.locked?
          record.errors[:base] << _("Cannot add/remove or change permissions related to a locked role.")
        end

        if record.all_verbs? && !record.verbs.empty?
          record.errors[:base] << N_("Cannot specify a verb if all_verbs is selected.")
        end

        if record.all_tags? && !record.tags.empty?
          record.errors[:base] << N_("Cannot specify a tag if all_tags is selected.")
        end

        if record.all_types? && (!record.all_verbs? || !record.all_tags?)
          record.errors[:base] << N_("Cannot specify all_types without all_tags and all_verbs")
        end

        begin
          ResourceType.check(record.resource_type.name, record.verb_values)
        rescue VerbNotFound => verb_error
          record.errors[:base] << verb_error.message
        rescue ResourceTypeNotFound => type_error
          record.errors[:base] << type_error.message
        end
      end
    end
  end
end
