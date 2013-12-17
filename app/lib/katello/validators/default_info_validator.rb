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
    class DefaultInfoValidator < ActiveModel::EachValidator

      MAX_SIZE = 256

      def validate_each(record, attribute, value)
        if value.class == ActiveRecord::AttributeMethods::Serialization::Attribute
          value = value.unserialized_value
        end

        value.each_key do |type|
          value[type].each do |key|
            if key.blank?
              if record.errors[attribute] << _("cannot contain blank keynames")
                return
              end
            end
            if key.size >= MAX_SIZE
              if record.errors[attribute] << _("must be less than %d characters") % MAX_SIZE
                return
              end
            end
          end
        end
      end
    end
  end
end
