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

module Navigation
  class Additions
    include Singleton

    @additions = []
    class << self

      # rubocop:disable TrivialAccessors
      def list
        @additions
      end

      def insert_after(key, node)
        new_addition(:after, key, node)
      end

      def insert_before(key, node)
        new_addition(:before, key, node)
      end

      def delete(key)
        new_addition(:delete, key, nil)
      end

      def clear
        @additions = []
      end

      private

      def new_addition(type, key, node)
        @additions << {:type=>type, :key=>key, :node=>node}
      end

    end
  end
end
