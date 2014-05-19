#
# Copyright 2014 Red Hat, Inc.
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
class UserNotice < Katello::Model
  self.include_root_in_json = false

  belongs_to :user, :inverse_of => :user_notices, :class_name => "::User"
  # FIXME, this will delete notice also for other users
  belongs_to :notice, :dependent => :destroy, :inverse_of => :user_notices

  def read!
    update_attributes! :viewed => true
  end

end
end
