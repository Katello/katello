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

module Validators
  class GpgKeyContentValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      #imported or pasted GpgKey must contain header and footer of an typical GPG Key
      unless value.match(/-{5}BEGIN PGP PUBLIC KEY BLOCK-{5}/) && value.match(/-{5}END PGP PUBLIC KEY BLOCK-{5}/)
        record.errors[attribute] << _("must contain GPG Key")
      end
    end
  end
end