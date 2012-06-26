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

class PulpSyncProgress
  attr_reader :total_size, :size_left, :total_count, :items_left, :error_details, :step

  def initialize(progress_attrs = {})
    @total_size = @size_left = @total_count = @items_left = 0

    unless progress_attrs.nil?
      ht = HashUtil.new
      @total_size  = ht.null_safe_get(progress_attrs, 0, ['size_total'])
      @size_left   = ht.null_safe_get(progress_attrs, 0, ['size_left'])
      @total_count = ht.null_safe_get(progress_attrs, 0, ['details','rpm','total_count'])
      @items_left  = ht.null_safe_get(progress_attrs, 0, ['details','rpm','items_left'])
      @error_details = ht.null_safe_get(progress_attrs, [], ['error_details'])
      @step = ht.null_safe_get(progress_attrs, 0, ['step'])
    end
  end
end

class PulpSyncStatus < PulpTaskStatus
  use_index_of TaskStatus
  
  FINISHED = "finished"
  ERROR = "error"
  RUNNING = "running"
  WAITING = "waiting"

  class Status < ::TaskStatus::Status
    NOT_SYNCED = :not_synced
  end

  def progress
    PulpSyncProgress.new(attributes['progress'])
  end
  
  def after_refresh
    correct_state
  end

  def self.pulp_task(pulp_status)
    task_status = PulpSyncStatus.find_by_uuid(pulp_status[:id])
    task_status = self.new { |t| yield t if block_given? } if task_status.nil?
    task_status.update_state(pulp_status)
  end

  def update_state(pulp_status)
    self.attributes = {
      :uuid => pulp_status[:id],
      :state => pulp_status[:state],
      :start_time => pulp_status[:start_time],
      :finish_time => pulp_status[:finish_time],
      :progress => pulp_status[:progress],
      :result => pulp_status[:result].nil? ? {:errors => [pulp_status[:exception], pulp_status[:traceback]]} : pulp_status[:result]
    }

    self.save! if not self.new_record?
    correct_state
    self
  end

  def correct_state
    if [FINISHED].include?(self.state) && !self.progress.error_details.blank?
      self.state = ERROR
      self.save! if not self.new_record?
    end
  end

end
