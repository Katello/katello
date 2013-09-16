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

module Authorization::Notice
  extend ActiveSupport::Concern

  READ_PERM_VERBS = [:read, :create, :update, :delete]

  included do
    def readable?
      User.allowed_to?(READ_PERM_VERBS, :organizations, nil, self)
    end

    def editable?
      User.allowed_to?([:delete, :create], :organizations)
    end

    def deletable?
      User.allowed_to?([:delete, :create], :organizations)
    end
  end

  module ClassMethods
    def creatable?(org)
      true
    end

    def any_readable?
      Organization.readable.count > 0
    end
  end

end
