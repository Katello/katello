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

module Util
  module Support
    def self.deep_copy object
      Marshal::load(Marshal.dump(object))
    end

    def self.time
      a = Time.now
      yield
      Time.now - a
    end

    def self.scrub(params, &block_to_match)
      params.keys.each do |key|
        if Hash === params[key]
          scrub(params[key], &block_to_match)
        elsif block_to_match.call(key, params[key])
          params[key]="[FILTERED]"
        end
      end
      params
    end

    # We need this so that we can return
    # empty search results on an invalid query
    # Basically this is a empty array with a total
    # method. We could ve user Tire::Result:Collection
    # But that class is way more involved
    def self.array_with_total a=[]
      def a.total
        size
      end
      a
    end

  end
end
