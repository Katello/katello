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

class Api::StatusController < Api::ApiController

  skip_before_filter :require_user

  def memory
    User.as :admin do
      objs = Hash.new(0)
      ObjectSpace.each_object do |o|
        objs[o.class] += 1
      end
      output = objs.sort_by{ |c,n| n }.last(30)
      render :text => PP.pp(output, "")
    end
  end

end
