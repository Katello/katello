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

module Experimental
  module Navigation
    module Menus
      class Subscriptions < Experimental::Navigation::Menu

        def initialize(organization)
          @key           = :subscriptions
          @display       = _("Subscriptions")
          @authorization = lambda{ organization }
          @type          = 'flyout'
          @items         = [
            Experimental::Navigation::Items::Subscriptions.new(organization),
            Experimental::Navigation::Items::Distributors.new(organization),
            Experimental::Navigation::Items::ActivationKeys.new(organization),
            Experimental::Navigation::Items::ImportHistory.new(organization)
          ]
          super
        end

      end
    end
  end
end
