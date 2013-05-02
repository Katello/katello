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

module SyncSchedulesHelper


  def hover_format item
    case item.interval
      when 'daily'
        _("Daily at %{time} from %{date} %{zone}") % {:time => item.plan_time, :date => item.plan_date, :zone => item.plan_zone}
      when 'weekly'
        _("Every %{day} at %{time} from %{date} %{zone}") % {:day => item.plan_day, :time => item.plan_time, :date => item.plan_date, :zone => item.plan_zone}
      else
        _("Hourly from %{date} - %{time} %{zone}") % {:date => item.plan_date, :time => item.plan_time, :zone => item.plan_zone}
    end
  end

end
