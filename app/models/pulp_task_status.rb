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



class PulpTaskStatus < TaskStatus
  use_index_of TaskStatus

  def refresh
    PulpTaskStatus.refresh(self)
  end

  def after_refresh
    #potentially used by child class, see PulpSyncStatus for example
  end

  def error
    self.result[:errors][0] if self.error? && self.result[:errors]
  end

  def self.wait_for_tasks async_tasks
    async_tasks = async_tasks.collect do |t|
      PulpTaskStatus.using_pulp_task(t)
    end

    timeout_count = 0
    while true
       begin
          break  if !any_task_running(async_tasks)
          timeout_count = 0
       rescue RestClient::RequestTimeout => e
          timeout_count += 1
          Rails.logger.error "Timeout in pulp occured: #{timeout_count}"
          raise e if timeout_count >= 10 #10 timeouts in a row, lets bail
          sleep 50 #if we got a timeout, lets backoff and let it catchup 
       end
       sleep 15
    end
    async_tasks
  end

  def self.using_pulp_task(pulp_status)
    if pulp_status.is_a? TaskStatus
      pulp_status
    else
      task_status = TaskStatus.find_by_uuid(pulp_status[:task_id])
      task_status = self.new { |t| yield t if block_given? } if task_status.nil?
      PulpTaskStatus.dump_state(pulp_status, task_status)
    end
  end

  def self.dump_state(pulp_status, task_status)
    task_status.attributes = {
      :uuid => pulp_status[:task_id],
      :state => pulp_status[:state] || pulp_status[:result],
      :start_time => pulp_status[:started],
      :finish_time => pulp_status[:completed],
      :progress => pulp_status,
      :result => pulp_status[:result].nil? ? {:errors => [pulp_status[:exception], pulp_status[:traceback]]} : pulp_status[:result]
    }
    task_status.save! if not task_status.new_record?
    task_status
  end

  def self.refresh task_status
    pulp_task = Resources::Pulp::Task.find([task_status.uuid]).first

    self.dump_state(task-status, pulp_task)
    task_status.after_refresh
  end

  protected

  def self.any_task_running(async_tasks)
    for t in async_tasks
      t.refresh
      sleep 0.5 # do not overload backend engines
      if not t.finished?
        return true
      elsif t.error?
        raise RuntimeError, t
      end
    end
    return false
  end


end
