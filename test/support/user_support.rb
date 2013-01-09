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



module UserSupport

  def self.create_hidden_user
    hidden_user = User.new(
      :roles => [],
      :username => "hidden-#{Password.generate_random_string(6)}",
      :password => Password.generate_random_string(25),
      :email => "#{Password.generate_random_string(10)}@localhost",
      :hidden=>true)
    hidden_user.save!
  end

  def self.destroy_hidden_user
    User.hidden.first.destroy if User.hidden.first
  end

end
