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

class ContentSearch::Cell
  include ContentSearch::Element
  display_attributes :id, :display, :hover, :content

  def as_json(options=nil)
    to_ret = {
        :id => id
    }
    to_ret[:content] = content unless content.nil?
    to_ret[:display] = display unless display.nil?
    to_ret[:hover] = self.hover.nil? ? '' : self.hover.call
    to_ret
  end

end
