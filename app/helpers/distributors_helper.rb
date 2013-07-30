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

module DistributorsHelper

  def render_rows(options)
    render :partial=>"distributors/list_distributors",
            :locals=>{:accessor=>options[:accessor], :columns=>options[:columns], :collection=>options[:collection], :name=>options[:name]}
  end

  def get_checkin(distributor)
    if distributor.checkin_time
      return  format_time(distributor.checkin_time)
    end
    _("Never checked in")
  end

  def get_registered(distributor)
    if distributor.created_time
      return  format_time(distributor.created_time)
    end
    _("Unknown registration date")
  end

  def get_uptime
    return '0 days'
  end

  def convert_time(item)
    format_time(Time.parse(item))
  end

  def distributor_environment_name distributor
    distributor.environment.name
  end

  def distributor_labelize name
    name.ascii_only? ? name.gsub(/[^a-z0-9\-_]/i,"_") : 'manifest'
  end

  def content_view_select(org, env)
    views = ContentView.readable(org).non_default.in_environment(env)
    choices = views.map {|v| [v.name, v.id]}
    select(:distributor, "content_view_id", choices,
             {:id=>"content_view_field"},
             {:tabindex => 2})
  end

  def distributor_content_view_opts(distributor)
    keys = {}
    distributor.environment.content_views.subscribable(current_organization).each do |view|
      keys[view.id] = view.default? ? _('Default View') : view.name
    end
    keys[""] = ""
    keys["selected"] = distributor.content_view_id || ""

    keys.to_json
  end

end
