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
      module Headpin
        class Administer < Experimental::Navigation::Menu

          def initialize
            @key           = :administer_headpin
            @display       = _("Administer")
            @authorization = true
            @type          = 'dropdown'
            @items         = [
              Experimental::Navigation::Items::Organizations.new,
              Experimental::Navigation::Items::Users.new,
              Experimental::Navigation::Items::Roles.new,
              Experimental::Navigation::Items::About.new
            ]
            super
          end

        end
      end
    end
  end
end
