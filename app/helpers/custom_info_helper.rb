#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module CustomInfoHelper

  # informable.custom_info returns an array containing a hash for each key-value pair like this:
  #
  # [ #<CustomInfo ... keyname: "asset_tag", value: "1234" ... >,
  #   #<CustomInfo ... keyname: "user", value: "thor" ... >,
  #   #<CustomInfo ... keyname: "user", value: "loki" ... >,
  #   #<CustomInfo ... keyname: "user", value: "odin" ... > ]
  #
  # consolidate is used to extract the meat of the returned CustomInfo array:
  #
  # { "asset_tag" => ["1234"],
  #   "user" => ["thor", "loki", "odin"] }
  def consolidate(info)
    return {} if info.empty?
    return info.group_by(&:keyname).map{|k,v| {k => v.map(&:value)}}.inject({}) { |hash, h| hash.merge(h) }
  end

end