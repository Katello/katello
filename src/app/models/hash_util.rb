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

class HashUtil
  def null_safe_get(hash, default, params)
    # Base case .. if we are down to the last param
    # lets actually try and find the value
    if params.size == 1
      begin
        # If we got back null lets assign the default
        return hash[params[0]] || default
      rescue Exception => e
        # If we errored out trying to fetch the value we return
        # default value.
        return default
      end
    end
    subhash = hash[params.first]
    # If we don't have a subhash don't try and recurse down
    if !subhash.nil? and !subhash.empty?
      self.null_safe_get(subhash, default, params[1..-1])
    else
      default
    end
  end
end