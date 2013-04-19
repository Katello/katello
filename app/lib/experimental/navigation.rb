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
    class Navigation

      def generate(menus)
        return prune_menu(menus)
      end

      def generate_main_menu(organization)
        generate([
          Experimental::Navigation::Items::Dashboard.new,
          Experimental::Navigation::Menus::Content.new(organization),
          Experimental::Navigation::Menus::Systems.new(organization)
        ])
      end

      def generate_admin_menu
        generate([
          Experimental::Navigation::Menus::Administer.new
        ])
      end

      def generate_user_menu(user)
        generate([
          Experimental::Navigation::Menus::User.new(user)
        ])
      end

      def prune_menu(menu_items)
        #have a list of menu items -> example [dashboard_hash, organizations_hash]
        #we need to prune that list based on
        #1. :if block wont pass (Permission issues  -> eg: user has no org access)   OR
        #2. No accessible children (-> eg: none of the second level items under org work out for the user)
        menu_items.delete_if do |menu|
          if menu.accessible?
             # :if block worked out.
             # Checking the children
             if defined? menu.items 
               # prune the sub menus
               prune_menu(menu.items) if menu.items

               #we want this item to be pruned
               # if there are no accessible children

               menu.items.empty?
             else
               # this is a leaf node
               # and its condition has already been evaluated to true
               # so keep it
               false
             end
          else
            # This node's condition has been evaluated to false
            # so prune it.
            true
          end
        end
      end

    end
  end
end
