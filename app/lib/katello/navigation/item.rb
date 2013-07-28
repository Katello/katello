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
    class Item
      include Navigation::Utils

      attr_reader :key, :display, :authorization, :url

      # Initalizer for the Navigation Item object
      #
      # @param key           [String]  unique token representing this item
      # @param display       [String]  the text that will be displayed when this item is rendered
      # @param authorization [Boolean] boolean that determines if this item should be pruned
      # @param url           [String]  the url associated with this navigation item
      def initialize(key, display, authorization, url)
        @key            = key
        @display        = display
        @url            = url
        @authorization  = authorization
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

      # Defines the JSON structure for navigation menu items
      #
      # @return [String] the JSON representation of the navigation item
      def as_json(*args)
        {
          :key    => @key,
          :display=> @display,
          :url    => @url
        }
      end

    end
  end
end
