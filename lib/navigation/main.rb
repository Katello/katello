#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
require 'navigation/content_management'
require 'navigation/administration'
require 'navigation/organization'
require 'navigation/dashboard'
require 'navigation/systems'
require 'navigation/main'

module Navigation
  def self.included(base)
    base.send :include, AdministrationMenu
    base.send :include, ContentMenu
    base.send :include, MainMenu
    base.send :include, OrganizationMenu
    base.send :include, DashboardMenu
    base.send :include, SystemMenu
  end

  module MainMenu
   def menu_main
    [ menu_dashboard, menu_contents, menu_systems ]
   end
  end

  module AdministrationMenu
    def admin_main
      [ menu_administration ]
    end
  end
end