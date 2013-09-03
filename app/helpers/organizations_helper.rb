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

module OrganizationsHelper

  def organization_servicelevel(org)
    _("%{sla}") %
      { :sla => ( (org.service_level.nil? || org.service_level.empty?) ? _("No Service Level Preference") : (_("Service Level %s") % org.service_level))}
  end

  def organization_servicelevel_edit(org)
    levels = {}
    org.service_levels.each do |level|
      levels["#{level}"] = _("Service Level %s") % level
      levels["#{level}"] = _("Service Level %s") % level
    end

    levels[''] = _("No Service Level Preference")

    levels["selected"] = organization_servicelevel(org)

    return levels.to_json
  end

end
