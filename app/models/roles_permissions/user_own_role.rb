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
    return (r = find_own_role) unless r.nil?

    begin
      role_name = "#{auser.username}_#{Password.generate_random_string(20)}"
    end while ::UserOwnRole.exists?(:name => role_name)

    proxy_association_owner.roles << (r = ::UserOwnRole.new(:name => role_name))
    r
  end

  def destroy_own_role
    return unless (r = find_own_role)
    r.destroy

    unless r.destroyed?
      Rails.logger.error error.to_s
    end
  end
end