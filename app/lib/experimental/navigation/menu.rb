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

      attr_accessor :key, :display, :type, :items

      # Initalizer for the Navigation Menu object
      def initialize(*args)
        process_additions(*args)
        generate
      end

      # Returns whether this item is accessible based on authorization rules
      #   Expects either a Proc or a boolean
      def accessible?
        if @authorization.is_a? Proc
          @authorization.call
        else
          @authorization
        end
      end

      # Dynamically sets the authorization rule
      def authorization=(authorization)
        @authorization = authorization
      end

      # Defines the JSON structure for navigation menus
      #
      # @return [String] the JSON representation of a navigation menu
      def as_json(*args)
        item = {
          :key    => @key,
          :display=> @display,
          :type   => @type,
          :items  => @items
        }

        return item
      end

      # Generates the menu structure
      def generate
        prune
      end

      def process_additions(*args)
        additions = Experimental::Navigation::Additions.list
        additions.each do |addition|

          index =  @items.index{|item| item.key.to_sym == addition[:key].to_sym}
          if index && addition[:type] == :delete
            @items.delete_at(index)
          elsif index
            index += 1 if (addition[:type] == :after)
            node = addition[:node].new(*args)
            @items.insert(index, node)
          end
        end

      end

      # Recursively prunes the menu items by checking if they are accessible
      def prune
        @items.delete_if do |item|
          if item.accessible?
            if item.is_a? Experimental::Navigation::Menu
              item.prune
              item.items.empty?
            else
              false
            end
          else
            true
          end
        end
      end

    end
  end
end
