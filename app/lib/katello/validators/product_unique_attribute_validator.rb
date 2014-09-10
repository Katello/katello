#
# Copyright 2014 Red Hat, Inc.
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
    class ProductUniqueAttributeValidator < ActiveModel::EachValidator

      def validate_each(record, attribute, value)
        unique = self.unique_attribute?(record, attribute, value)

        if !unique
          message = _("Product with %{attribute} '%{id}' already exists in this organization.") %
                    {:attribute => attribute, :id => value}
          record.errors[attribute] << message
        end
      end

      def unique_attribute?(record, attribute, value)
        unique = true

        if record.provider && !record.provider.redhat_provider? && record.send("#{attribute}_changed?")
          if Product.in_org(record.provider.organization).where(attribute => value).exists?
            unique = false
          end
        end

        unique
      end

    end
  end
end
