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

# TODO: Remove this module and all inclusions of it in models
# once this is added to Foreman core https://github.com/theforeman/foreman/pull/1384
module Katello
  module Authorization
    extend ActiveSupport::Concern

    included do
      def authorized?(permission)
        ::User.current.can?(permission, self)
      end
    end
  end
end
