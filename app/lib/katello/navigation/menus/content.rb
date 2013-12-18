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
    class Content < Navigation::Menu

      def initialize(organization)
        @key           = :content
        @display       = _("Content")
        @type          = 'dropdown'
        @authorization = lambda{ organization }
        @items         = [
          Navigation::Items::Environments.new(organization),
          Navigation::Menus::Subscriptions.new(organization),
          Navigation::Menus::Providers.new(organization),
          Navigation::Menus::SyncManagement.new(organization),
          Navigation::Items::ContentViewDefinitions.new(organization),
          Navigation::Items::ContentSearch.new(organization),
          Navigation::Menus::Changesets.new(organization)
        ]
        super
      end

    end
  end
end
end
