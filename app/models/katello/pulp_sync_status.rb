module Katello
  class PulpSyncProgress
    attr_reader :total_size, :size_left, :total_count, :items_left, :error_details, :step

    def initialize(progress_attrs = {})
      @total_size = @size_left = @total_count = @items_left = 0

      unless progress_attrs.nil?
        #depending on whether this is a history item, or current sync structure may be different
        ht = HashUtil.new

        details = ht.null_safe_get(progress_attrs, nil, %w(progress_report yum_importer content)) ||
                  ht.null_safe_get(progress_attrs, nil, %w(progress_report details packages sync_report)) ||
                  ht.null_safe_get(progress_attrs, nil, %w(progress_report iso_importer))

        #if the task is waiting, it wont have a progress report
        progress_attrs['progress_report'] ||= {}

        if progress_attrs['progress_report']['iso_importer']
          @total_size  = ht.null_safe_get(details, 0, ['total_bytes'])
          @size_left   = @total_size - ht.null_safe_get(details, 0, ['finished_bytes'])
          @total_count = ht.null_safe_get(details, 0, ['num_isos'])
          @items_left  = @total_count - ht.null_safe_get(details, 0, ['num_isos_finished'])

        else
          @total_size  = ht.null_safe_get(details, 0, ['size_total'])
          @size_left   = ht.null_safe_get(details, 0, ['size_left'])
        end

        @error_details = errors(progress_attrs['progress_report'])
        @step = ht.null_safe_get(progress_attrs, 0, ['step'])
      end
    end

    private

    def errors(progress)
      if progress[:yum_importer]
        details = progress[:yum_importer]
      elsif progress[:details]
        details = progress[:details]
      end

      format_errors(details)
    end

    # Possible formats coming from pulp
    #
    # We ignore this case:
    #   {'finished_count' => {}}
    #
    # We extract from this case:
    #   {'content' => {'error' => ''},
    #    'errata' => {'error' => ''},
    #    'packages' => {'error' => ''},
    #    'metadata' => {'error_details => ''}
    #   }
    def format_errors(details)
      errors = {messages: [], details: []}

      if details && !details.key?(:finished_count)
        details.each do |step, report|
          if step == "content"
            parse_content(report, errors)
          else
            parse_generic(report, errors)
          end
        end
      end

      errors
    end

    def parse_content(details, errors)
      timeout = false

      details['error_details'].each do |error|
        if error['error_code'] == 37
          timeout = true
        end
      end

      if timeout
        errors[:messages] << _('One or more packages failed to sync properly.')
        errors[:details].concat(details[:error_details]) if details[:error_details].present?
      else
        parse_generic(details, errors)
      end
    end

    def parse_generic(details, errors)
      errors[:messages] << details[:error] if details[:error].present?
      errors[:details].concat(details[:error_details]) if details[:error_details].present?
    end
  end
end

module Katello
  class PulpSyncStatus < TaskStatus
    HISTORY_ERROR = 'failed'.freeze
    HISTORY_SUCCESS = 'success'.freeze
    FINISHED  = "finished".freeze
    ERROR     = "error".freeze
    RUNNING   = "running".freeze
    WAITING   = "waiting".freeze
    CANCELED  = "canceled".freeze

    class Status < TaskStatus::Status
      NOT_SYNCED = :not_synced
    end

    def self.dump_state(pulp_status, task_status)
      if !pulp_status.key?(:state) && pulp_status[:result] == "success"
        # Note: if pulp_status doesn't contain a state, the status is coming from pulp sync history
        pulp_status[:state] = Status::FINISHED.to_s
      end

      task_status.attributes = {
        :uuid => pulp_status[:task_id],
        :state => pulp_status[:state] || pulp_status[:result],
        :start_time => pulp_status[:start_time] || pulp_status[:start_time],
        :finish_time => pulp_status[:finish_time],
        :progress => pulp_status,
        :result => pulp_status[:result].nil? ? {:errors => [pulp_status[:exception], pulp_status[:traceback]]} : pulp_status[:result]
      }
      task_status.save! unless task_status.new_record?
      task_status
    end

    def progress
      PulpSyncProgress.new(attributes['progress'])
    end

    def after_refresh
      correct_state
    end

    def self.pulp_task(pulp_status)
      task_status = PulpSyncStatus.find_by(:uuid => pulp_status[:id])
      task_status = self.new { |t| yield t if block_given? } if task_status.nil?
      task_status.update_state(pulp_status)
    end

    def update_state(pulp_status)
      PulpSyncStatus.dump_state(pulp_status, self)
      correct_state
      self
    end

    def correct_state
      if [FINISHED].include?(self.state) && self.progress.error_details[:messages].present?
        self.state = ERROR
        self.save! unless self.new_record?
      end
    end
  end
end
