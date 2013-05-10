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

module SystemsHelper

  def render_rows(options)
    render :partial=>"systems/list_systems",
            :locals=>{:accessor=>options[:accessor], :columns=>options[:columns], :collection=>options[:collection], :name=>options[:name]}
  end

  def get_checkin(system)
    if system.checkin_time
      return  format_time(system.checkin_time)
    end
    _("Never checked in")
  end

  def get_registered(system)
    if system.created_time
      return  format_time(system.created_time)
    end
    _("Unknown registration date")
  end

  def get_uptime
    return '0 days'
  end

  def convert_time(item)
    format_time(Time.parse(item))
  end

  def architecture_select
    select(:arch, "arch_id", System.architectures.invert,
             {:prompt => _('Select Architecture'), :id=>"arch_field"}, {:tabindex => 3})
  end

  def content_view_select(org, env)
    views = ContentView.readable(org).non_default.in_environment(env)
    choices = views.map {|v| [v.name, v.id]}
    select(:system, "content_view_id", choices,
             {:prompt => no_content_view, :id=>"content_view_field"},
             {:tabindex => 2})
  end

  def system_content_view_opts(system)
    keys = {}
    if system.environment
      content_views = system.environment.content_views.subscribable(current_organization)
    else
      content_views = ContentView.subscribable(current_organization)
    end
    content_views.non_default.each do |view|
      keys[view.id] = view.name
    end
    keys[""] = ""
    keys["selected"] = system.content_view_id || ""

    keys.to_json
  end

  def virtual_buttons
    raw [radio_button("system_type","virtualized", "physical", :checked=>true, :tabindex => 5 ),
    content_tag(:label, _("Physical"), :for => 'system_type_virtualized_physical'),
    radio_button("system_type","virtualized", "virtual", :tabindex => 6 ),
    content_tag(:label, _("Virtual"), :for => 'system_type_virtualized_virtual')].join(' ')
  end

  def errata_type_class errata
    case errata.e_type
      when  Errata::SECURITY
        return "security_icon"
      when  Errata::ENHANCEMENT
        return "enhancement_icon"
      when  Errata::BUGZILLA
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

  def system_releasevers_edit system, releases
    vers = {}
    releases.each { |ver|
      vers[ver] = ver
    }

    vers[""] = ""
    vers["selected"] = system[:releaseVer]

    return vers.to_json
  end

  def system_servicelevel system
    if system.serviceLevel.blank?
      org_sla = system.organization.service_level
      sla = org_sla.blank? ? _("No Service Level Preference") : (_("Organization Service Level %s") % org_sla)
    else
      sla = _("Service Level %s") % system.serviceLevel
    end

    _("Auto-attach %{val}, %{sla}") % {:val => system.autoheal ? _("On") : _("Off"), :sla => sla}
  end

  def system_servicelevel_edit system
    levels = {}
    system.organization.service_levels.each { |level|
      levels["1#{level}"] = _("Auto-attach On, Service Level %s") % level
      levels["0#{level}"] = _("Auto-attach Off, Service Level %s") % level
    }

    levels['1'] = _("Auto-attach On, Use Organization Service Level")
    levels['0'] = _("Auto-attach Off, Use Organization Service Level")

    levels["selected"] = system_servicelevel(system)

    return levels.to_json
  end

  def system_environment_name system
    system.environment.name
  end

  def system_status_message system

    if system.compliant?
      until_time = @system.compliant_until
      message = until_time ? _("Subscriptions are Current Until %s") % format_time(until_time) : _("Subscriptions are Current")
    else
      general_message = system.compliance_color == 'yellow' ? _("Insufficient Subscriptions are Attached to This System") : _('Subscriptions are not Current')
      message = nil
      key = nil
      system.compliance['reasons'].each do |reason|
        message = key.nil? ? reason['message'] : general_message

        # If there are more than one type of reason, return the general message
        if !key.nil? && key != reason['key']
          return general_message
        end
      end

      # In case the system is not compliant and there are no messages
      message = general_message if key.nil?
    end

    message
  end

  def system_subscription_status_message system, product
    messages = []
    system.compliance['reasons'].each do |reason|
      if reason['attributes']['product_id'] == product['productId']
        messages << reason['message']
      end
    end
    messages.join(' ')
  end

end
