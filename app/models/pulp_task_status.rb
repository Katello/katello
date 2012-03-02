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


  def self.using_pulp_task(sync)
    t = self.new { |t| yield t if block_given? }
    PulpTaskStatus.dump_state(sync, t)
  end

  def self.dump_state(pulp_status, task_status)
    task_status.attributes = {
    :uuid => pulp_status[:id],
    :state => pulp_status[:state],
    :start_time => pulp_status[:start_time],
    :finish_time => pulp_status[:finish_time],
    :progress => pulp_status[:progress],
    :result => pulp_status[:result].nil? ? {:errors => [pulp_status[:exception], pulp_status[:traceback]]} : pulp_status[:result]
    }
    task_status.save! if not task_status.new_record?
    task_status
  end

  def refresh
    PulpTaskStatus.refresh(self)
  end

  def error
    self.result[:errors][0] if self.error? && self.result[:errors]
  end

  def self.refresh task_status
    pulp_task = Pulp::Task.find([task_status.uuid]).first
    task_status.attributes = {
        :state => pulp_task[:state],
        :finish_time => pulp_task[:finish_time],
        :progress => pulp_task[:progress],
        :result => pulp_task[:result].nil? ? {:errors => [pulp_task[:exception], pulp_task[:traceback]]} : pulp_task[:result]
    }
    task_status.save! if not task_status.new_record?
    task_status
  end

  protected

  def self.any_task_running(async_tasks)
    for t in async_tasks
      t.refresh
      sleep 0.5 # do not overload backend engines
      if not t.finished?
        return true
      elsif t.error?
        raise RuntimeError, t.error
      end
    end
    return false
  end


end
