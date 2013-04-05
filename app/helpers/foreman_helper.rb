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

module ForemanHelper

  def dhcp_select(object, name, selected=nil)
    smart_proxy_select :dhcp, object, name, selected
  end

  def tftp_select(object, name, selected=nil)
    smart_proxy_select :tftp, object, name, selected
  end

  def dns_select(object, name, selected=nil)
    smart_proxy_select :dns, object, name, selected
  end

  def smart_proxy_select(type, object, name, selected=nil)

    choices = Foreman::SmartProxy.all(:type=>type).map {|d| [d.name, d.id]}
    return _("No smart proxy with %s feature found.") % type.to_s if choices.empty?
    choices = [nil] + choices

    if selected.nil? && object.respond_to?(name)
      selected = object.send(name)
    end

    select object, name, choices, {
        :selected=>selected
      }, {
        :id=>name,
        :style=>"width: 200px",
        'data-placeholder'=>_("Choose %s...") % type
      }
  end

  def domain_select(object, name, selected=nil)

    choices = Foreman::Domain.all.map {|d| [d.name, d.id]}
    return _("No domains found.") if choices.empty?

    if selected.nil? && object.respond_to?(name)
      selected = object.send(name)
    end

    select object, name, choices, {
        :selected=>selected
      }, {
        :id=>name,
        :multiple=>"true",
        :style=>"width: 400px; height: 200px;",
        'data-placeholder'=>_("Choose domains...")
      }
  end

  def os_select(object, name, selected=nil)

    choices = Foreman::OperatingSystem.all.map {|os| [os.to_label, os.id]}
    return _("No operating systems found.") if choices.empty?

    if selected.nil? && object.respond_to?(name)
      selected = object.send(name)
    end

    select object, name, choices, {
        :selected=>selected
      }, {
        :id=>name,
        :multiple=>"true",
        :style=>"width: 400px; height: 200px;",
        'data-placeholder'=>_("Choose operating systems...")
      }
  end

end
