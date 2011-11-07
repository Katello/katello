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

module UsersHelper

  def mask_password user
    return "" if user.password.nil?
    user.password.gsub(/./, "&#9679;")
  end

  def organization_select(org_id=nil)
    select(:org_id, "org_id",
           current_user.allowed_organizations.map {|a| [a.name, a.id]},
           {:prompt => _('Select Organization'), :id=>"org_field",
           :selected => (org_id ||= current_organization.id)})
  end

end
