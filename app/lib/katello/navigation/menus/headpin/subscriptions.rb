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
  module Navigation
    module Menus
      module Headpin
        class Subscriptions < Navigation::Menu

          def initialize(organization)
            @key           = :subscriptions
            @display       = _("Subscriptions")
            @authorization = lambda{ organization }
            @type          = 'dropdown'
            @items         = [
              Navigation::Items::Subscriptions.new(organization),
              Navigation::Items::Distributors.new(organization),
              Navigation::Items::ActivationKeys.new(organization),
              Navigation::Items::ImportHistory.new(organization)
            ]
            super
          end
        end
      end
    end
  end
end
