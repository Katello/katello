module Katello
  module OrganizationsHelper
    def organization_servicelevel(org)
      _("%{sla}") %
        { :sla => ((org.service_level.nil? || org.service_level.empty?) ? _("No Service Level Preference") : (_("Service Level %s") % org.service_level))}
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
end
