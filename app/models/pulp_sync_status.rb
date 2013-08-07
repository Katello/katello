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

class PulpSyncProgress
  attr_reader :total_size, :size_left, :total_count, :items_left, :error_details, :step

  def initialize(progress_attrs = {})
    @total_size = @size_left = @total_count = @items_left = 0

    unless progress_attrs.nil?
      #depending on whether this is a history item, or current sync structure may be different
      ht = HashUtil.new

      details =  ht.null_safe_get(progress_attrs, nil, ['progress','yum_importer', 'content'] )    ||
            ht.null_safe_get(progress_attrs, nil, ['progress', 'details','packages', 'sync_report'] )

      @total_size  = ht.null_safe_get(details, 0, ['size_total'])
      @size_left   = ht.null_safe_get(details, 0, ['size_left'])
      @total_count = ht.null_safe_get(details, 0, ['items_total'])
      @items_left  = ht.null_safe_get(details, 0, ['items_left'])
      @error_details = ht.null_safe_get(progress_attrs, [], ['error_details'])
      @step = ht.null_safe_get(progress_attrs, 0, ['step'])
    end
  end
end

class PulpSyncStatus < PulpTaskStatus
  use_index_of TaskStatus if Katello.config.use_elasticsearch

  HISTORY_ERROR = 'failed'
  HISTORY_SUCCESS = 'success'
  FINISHED  = "finished"
  ERROR     = "error"
  RUNNING   = "running"
  WAITING   = "waiting"
  CANCELED  = "canceled"

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
    PulpSyncStatus.dump_state(pulp_status, self)
    correct_state
    self
  end

  def correct_state
    if [FINISHED].include?(self.state) && !self.progress.error_details.blank?
      self.state = ERROR
      self.save! if not self.new_record?
    end
  end

  # Pulp history items are moved from the task item, but are different
  #  and as a result we need to convert the structure
  # @option [Array] history_list list of pulp sync history hashes
  def self.convert_history(history_list)
    #history item attributes
    #["_id", "_ns", "added_count", "completed", "details", "error_message", "exception", "id",
    # "importer_id", "importer_type_id", "removed_count", "repo_id", "result", "started", "summary",
    # "traceback", "updated_count"]

    #task status attributes
    #["task_group_id", "exception", "traceback", "_href", "task_id", "call_request_tags", "reasons",
    # "start_time", "tags", "state", "finish_time", "dependency_failures", "schedule_id", "progress",
    # "call_request_group_id", "call_request_id", "principal_login", "response", "result"]
    history_list.collect do |history|
      result = history['result']
      result = ERROR if result == HISTORY_ERROR
      result = FINISHED if result == HISTORY_SUCCESS
      {
          :state =>  result,
          :progress => {:details=> history["details"]},
          :finish_time => history['completed'],
          :start_time => history['started']
      }.with_indifferent_access
    end
  end

end
