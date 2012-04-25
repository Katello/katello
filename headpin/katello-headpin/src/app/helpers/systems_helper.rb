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

module SystemsHelper
  
  def render_rows(options)
    render :partial=>"systems/list_systems",  
            :locals=>{:accessor=>options[:accessor], :columns=>options[:columns], :collection=>options[:collection], :name=>options[:name]}
  end
  
  def get_checkin(system)
    if system.checkinTime
      return  format_time(system.checkinTime)
    end
    _("Never checked in.")
  end

  def get_uptime
    return '0 days'
  end

  def convert_time(item)
    format_time(Time.parse(item))
  end

  def architecture_select
    select(:arch, "arch_id", System.architectures.invert,
             {:prompt => _('Select Architecture'), :id=>"arch_field", :tabindex => 2})
  end

  def virtual_buttons
    radio_button("system_type","virtualized", "physical", :checked=>true ) + _("Physical") +
    radio_button("system_type","virtualized", "virtual" ) + _("Virtual")
  end
  
  def errata_type_class errata
    case errata.e_type
      when  Glue::Pulp::Errata::SECURITY
        return "security_icon"
      when  Glue::Pulp::Errata::ENHANCEMENT
        return "enhancement_icon"
      when  Glue::Pulp::Errata::BUGZILLA
        return "bugzilla_icon"
    end
  end

  def system_type system

    return _("Guest") if system.guest == 'true'

    case system
      when Hypervisor
        _("Hypervisor")
      else
        _("Host")
    end
  end

  def system_releasevers_edit system
    vers = {}
    system.available_releases.each { |ver|
      vers[ver] = ver
    }

    vers[""] = ""
    vers["selected"] = system[:releaseVer]

    return vers.to_json
  end

  def system_servicelevel system
    if system.autoheal
      if system.serviceLevel == ""
        _("Auto-subscribe On, No Service Level Preference")
      else
        _("Auto-subscribe On, Service Level %s") % system.serviceLevel
      end
    else
      _("Auto-subscribe Off")
    end
  end

  def system_servicelevel_edit system
    levels = {}
    system.organization.service_levels.each { |level|
      levels[level] = _("Auto-subscribe On, Service Level %s") % level
    }

    levels["Auto-subscribe On"] = _("Auto-subscribe On, No Service Level Preference")
    levels["Auto-subscribe Off"] = _("Auto-subscribe Off")

    levels["selected"] = system_servicelevel(system)

    return levels.to_json
  end

end
