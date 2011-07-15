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

class TaskStatus < ActiveRecord::Base
  belongs_to :status, :polymorphic => true

  class Status
    WAITING = :waiting
    RUNNING = :running
    ERROR = :error
    FINISHED = :finished
    CANCELLED = :cancelled
    TIMED_OUT = :timed_out
  end

  include Authorization
  belongs_to :organization

  def self.for_pulp(organization, sync)
    TaskStatus.create!(
        :uuid => sync.id,
        :state => sync.state,
        :start_time => sync.start_time,
        :finish_time => sync.finish_time,
        :result => sync.result.nil? ? {:errors => [sync.exception, sync.traceback]}.to_json : sync.result,
        :remote_system => 'pulp',
        :organization => organization
    )
  end

  def refresh
    return self if (remote_system.nil? || remote_system != 'pulp')

    pulp_task = Pulp::Task.find(uuid)
    update_attributes!(:state => pulp_task[:state], :finish_time => pulp_task[:finish_time], :result => pulp_task[:result].nil? ? {:errors => [pulp_task[:exception], pulp_task[:traceback]]}.to_json : pulp_task[:result])
    self
  end

end