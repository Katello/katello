# encoding: utf-8
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
  class GpgKeyContentValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value
        GpgKeyContentValidator.validate_line_length(record, attribute, value)
        gpg_key_line_array = value.split("\n")
        gpg_key_line_array.delete("")

        if gpg_key_line_array.first.match(/-{5}BEGIN PGP PUBLIC KEY BLOCK-{5}/) && gpg_key_line_array.last.match(/-{5}END PGP PUBLIC KEY BLOCK-{5}/)

          gpg_key_line_array.shift
          gpg_key_line_array.pop

          if gpg_key_line_array.empty?
            record.errors[attribute] << _("must contain valid Public GPG Key")
          else
            unless gpg_key_line_array.drop(1).join.match(/[a-zA-Z0-9+\/=]*/)
              record.errors[attribute] << _("must contain valid Public GPG Key")
            end
          end

        else
          record.errors[attribute] << _("must contain valid Public GPG Key")
        end

      else
        record.errors[attribute] << _("must contain GPG Key")
      end

    end

    def self.validate_line_length(record, attribute, value)
      value.each_line do |line|
        record.errors[attribute] << _("must contain valid  Public GPG Key") if line.length > GpgKey::MAX_CONTENT_LINE_LENGTH
      end
    end

  end
end
end
