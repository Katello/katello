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
    select(:arch, "arch_id",
             System.architectures {|a| [a.id, a.name]},
             {:prompt => _('Select Architecture'), :id=>"arch_field", :tabindex => 2})
  end

  def virtual_buttons
    radio_button("system_type","virtualized", "physical", :checked=>true ) + _("Physical") +
    radio_button("system_type","virtualized", "virtual" ) + _("Virtual")
  end

end
