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

module DashboardHelper

  def dashboard_entry name, partial
    render :partial=>"entry", :locals=>{:name=>name, :partial=>partial}
  end

  def user_notices
    trim_length = 45
    current_user.notices.order("created_at DESC").limit(10).collect{|note|
      if note.text.length > trim_length + 3
        text = note.text[0..trim_length] + '...'
      else
        text =note.text
      end
      {:text=>text, :level=>note.level, :date=>note.created_at}
    }
  end

  def promotions
    return  Changeset.joins(:task_status).
        where("changesets.environment_id"=>KTEnvironment.changesets_readable(current_organization)).
        order("task_statuses.updated_at DESC").limit(5)
  end

  def cs_class cs
    if cs.state === Changeset::PROMOTED
      "check_icon"
    elsif cs.state === Changeset::PROMOTING && cs.task_status.start_time
      "gear_icon"  #running
    else
      "clock_icon" #pending
    end
  end

  def cs_message cs
    if cs.state === Changeset::PROMOTED
      _("Success")
    elsif cs.state === Changeset::PROMOTING && cs.task_status.start_time
      _("Promoting")
    else
      _("Pending")
    end        
  end

  def systems_list
    System.readable(current_organization).limit(10)
  end

end
