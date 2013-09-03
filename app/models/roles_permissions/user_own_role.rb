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

module RolesPermissions::UserOwnRole
  include  ::ProxyAssociationOwner

  def find_own_role
    where(:type => 'UserOwnRole').first
  end

  def find_or_create_own_role(auser)
    role = find_own_role
    return role if role

    role_name = ""
    loop do
      role_name = "#{auser.username}_#{Password.generate_random_string(20)}"
      break unless ::UserOwnRole.exists?(:name => role_name)
    end

    proxy_association_owner.roles << (role = ::UserOwnRole.new(:name => role_name))
    role
  end

  def destroy_own_role
    role = find_own_role
    return unless role
    role.destroy

    unless role.destroyed?
      Rails.logger.error error.to_s
    end
  end
end