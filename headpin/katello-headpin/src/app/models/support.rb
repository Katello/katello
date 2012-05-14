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

module Support
  def Support.deep_copy object
    Marshal::load(Marshal.dump(object))
  end

  def Support.time
    a = Time.now
    yield
    Time.now - a
  end

  def Support.scrub(params, &block_to_match)
    params.keys.each do |key|
      if Hash === params[key]
        scrub(params[key], &block_to_match)
      elsif block_to_match.call(key, params[key])
         params[key]="[FILTERED]"
      end
    end
    params
  end

end
