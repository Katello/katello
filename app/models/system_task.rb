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

class SystemTask < ActiveRecord::Base
  belongs_to :system
  belongs_to :task_status

  def self.refresh(ids)
    ids.each do |id|
      TaskStatus.find(id).refresh_pulp
    end
  end

  def self.refresh_for_system(sid)
    query = SystemTask.select(:task_status_id).joins(:task_status).where(:system_id => sid)
    ids = query.where("task_statuses.state"=>[:waiting, :running]).collect {|row| row[:task_status_id]}
    refresh(ids)
    TaskStatus.where("task_statuses.id in (#{query.to_sql})")
  end
end