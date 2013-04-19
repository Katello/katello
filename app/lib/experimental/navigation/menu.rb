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
    class Menu

      attr_reader :key, :display, :type, :items

      # Initalizer for the Navigation Menu object
      #
      # @param key           [String]  unique token representing this menu
      # @param display       [String]  the text that will be displayed when this menu is rendered
      # @param authorization [Boolean] boolean that determines if this menu should be pruned
      # @param type          [String]  the type of navigation menu, e.g. 'dropdown' or 'flyout'
      # @param items         [Array]   the navigation items to anchor to this menu
      def initialize(key, display, authorization, type, items)
        @key            = key
        @display        = display
        @type           = type
        @items          = items
        authorization   = authorization
      end
      
      def accessible?
        if @authorization.is_a? Proc
          @authorization.call
        else
          @authorization
        end
      end

      def authorization=(authorization)
        @authorization = authorization
      end

      # Defines the JSON structure for navigation menus
      #
      # @return [String] the JSON representation of a navigation menu
      def to_json
        item = {
          :key    => @key,
          :display=> @display,
          :type   => @type,
          :items  => @items
        }

        return item.to_json
      end

    end
  end
end
