module Katello
  class ErrataApplication < Katello::Model
    belongs_to :host, class_name: '::Host::Managed', inverse_of: :errata_applications
    belongs_to :task, class_name: 'ForemanTasks::Task', optional: true, inverse_of: false
    belongs_to :user, class_name: '::User', optional: true, inverse_of: :errata_applications

    validates :host, :errata_ids, :applied_at, :status, presence: true
    validates :status, inclusion: { in: %w[success error warning cancelled] }
    validate :errata_ids_must_be_array

    scoped_search :on => :applied_at, :complete_value => false
    scoped_search :on => :status, :complete_value => true

    scope :successful, -> { where(status: 'success') }
    scope :failed, -> { where(status: %w[error warning cancelled]) }
    scope :for_host, ->(host) { where(host: host) }
    scope :for_erratum, ->(erratum) { where("? = ANY(errata_ids)", erratum.errata_id) }
    scope :since, ->(date) { where('applied_at >= ?', date) }
    scope :up_to, ->(date) { where('applied_at <= ?', date) }

    default_scope { order(applied_at: :desc) }

    validates :task_id, uniqueness: { scope: :host_id }, allow_nil: true

    def errata_ids_must_be_array
      errors.add(:errata_ids, "must be an array") unless errata_ids.is_a?(Array)
      errors.add(:errata_ids, "cannot be empty") if errata_ids.blank?
    end

    # Record errata applications from a completed task
    # @param task [ForemanTasks::Task] The completed task
    # @param action [Dynflow::Action] The action object
    # @return [ErrataApplication, nil] Created application record or nil if skipped
    def self.record_from_task(task, action)
      return nil unless task

      host_id = extract_host_id_from_task(task)
      return nil unless host_id

      host = ::Host::Managed.find_by(id: host_id)
      return nil unless host

      errata_string_ids = extract_errata_ids_from_task(task)
      return nil if errata_string_ids.blank?

      # Reload task to get the latest result status
      task.reload
      status = determine_status(task, action)
      applied_at = task.ended_at || Time.zone.now
      user = task.user

      begin
        create!(
          host: host,
          errata_ids: errata_string_ids,
          task: task,
          user: user,
          applied_at: applied_at,
          status: status
        )
      rescue ActiveRecord::RecordInvalid => e
        if e.record.errors.of_kind?(:task_id, :taken)
          Rails.logger.warn("Skipped duplicate errata application: task=#{task.id}, host=#{host.name}")
          nil
        else
          raise
        end
      end
    end

    # Extract host ID from task input
    def self.extract_host_id_from_task(task)
      if dynflow_initialized?
        begin
          input = task.input

          if input
            if input['host'].is_a?(Hash)
              return input['host']['id']
            elsif input['host_id']
              return input['host_id']
            end
          end
        rescue StandardError
          # Fall through to template_invocation fallback
        end
      end

      task.template_invocation&.host_id
    end

    # Extract errata IDs from task
    # @param task [ForemanTasks::Task] The task to extract from
    def self.extract_errata_ids_from_task(task)
      if dynflow_initialized?
        begin
          input = task.input

          # Try to get errata from input if available
          if input.present?
            errata = input['errata'] || input['content']
            return errata if errata.present?

            # Check job_features to decide extraction method
            if input['job_features']&.include?('katello_errata_install_by_search')
              return extract_from_script(task)
            end
          end
        rescue StandardError
          # Fall through to template_invocation fallback
        end
      end

      # Fall back to template invocation input
      return [] unless task.template_invocation
      extract_from_template_input(task)
    end

    def self.extract_from_script(task)
      return [] unless task.execution_plan_action

      # The script is in the ProxyAction, find it without hardcoding array index
      proxy_action = task.execution_plan_action.all_planned_actions(::Actions::RemoteExecution::ProxyAction).first
      # Fallback to legacy array access if ProxyAction not found (shouldn't happen)
      proxy_action ||= task.execution_plan_action.execution_plan.actions.find do |action|
        action.is_a?(::Actions::RemoteExecution::ProxyAction) && action.input['script'].present?
      end

      return [] unless proxy_action

      script = proxy_action.input['script'] || ''
      found = script.lines.find { |line| line.start_with?('# RESOLVED_ERRATA_IDS=') } || ''
      ids = (found.chomp.split('=', 2).last || '').split(',')
      ids.map(&:strip).reject(&:blank?)
    end

    def self.extract_from_template_input(task)
      # Search-based template (katello_errata_install_by_search) stores search query in template input,
      # not errata IDs. Only list-based template (katello_errata_install) stores comma-separated IDs.
      # This method should only be called for list-based templates when Dynflow is not available.

      value = ::TemplateInvocationInputValue
        .joins(:template_input)
        .where(template_invocation_id: task.template_invocation.id)
        .where("template_inputs.name = ?", 'errata')
        .first&.value

      parse_comma_separated_errata_ids(value)
    end

    def self.parse_comma_separated_errata_ids(value)
      return [] if value.blank?
      value.split(',').map(&:strip).reject(&:blank?)
    end
    private_class_method :parse_comma_separated_errata_ids

    # Determine application status from task and action
    def self.determine_status(task, action)
      if task.result.present? && task.result != 'pending'
        task.result.to_s
      else
        # Fallback: check action error
        action&.error.present? ? 'error' : 'success'
      end
    end

    # Check if Dynflow is initialized and available
    # @return [Boolean] true if Dynflow can be safely accessed
    def self.dynflow_initialized?
      defined?(ForemanTasks) &&
        ForemanTasks.respond_to?(:dynflow) &&
        ForemanTasks.dynflow.initialized?
    rescue StandardError
      false
    end
    private_class_method :dynflow_initialized?
  end
end
