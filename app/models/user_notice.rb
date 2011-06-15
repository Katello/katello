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

class UserNotice < ActiveRecord::Base
  include Authorization

  belongs_to :user
  belongs_to :notice

  def check_permissions operation
    # anybody can create user_notice relationships
    return true if operation == :create
    # only notice owner can update or destroy
    if operation == :update or operation == :destroy
      return true if user.id and User.current and user.id == User.current.id
    end
    false
  end

end
