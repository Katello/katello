module Katello
  class ErrataApplication < Katello::Model
    belongs_to :host, class_name: '::Host::Managed', inverse_of: :errata_applications
    belongs_to :task, class_name: 'ForemanTasks::Task', optional: true, inverse_of: false
    belongs_to :user, class_name: '::User', optional: true, inverse_of: :errata_applications

    validates :host, :errata_ids, :applied_at, :status, presence: true
    validates :status, inclusion: { in: %w[success error warning cancelled] }
    validate :errata_ids_must_be_array

    scope :successful, -> { where(status: 'success') }
    scope :failed, -> { where(status: %w[error warning cancelled]) }
    scope :for_host, ->(host) { where(host: host) }
    scope :for_erratum, ->(erratum) { where("? = ANY(errata_ids)", erratum.id) }
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
    # @param action [Dynflow::Action] Optional action object
    # @return [Array<ErrataApplication>] Created application records
    def self.record_from_task(task, action = nil)
      return [] unless task

      host_id = extract_host_id_from_task(task)
      return [] unless host_id

      host = ::Host::Managed.find_by(id: host_id)
      return [] unless host

      errata_string_ids = extract_errata_ids_from_task(task)
      return [] if errata_string_ids.blank?

      # Convert errata string IDs to database IDs
      errata = Katello::Erratum.where(errata_id: errata_string_ids)
      errata_ids = errata.pluck(:id)
      return [] if errata_ids.blank?

      status = determine_status(task, action)
      applied_at = task.ended_at || Time.zone.now
      user = task.user

      begin
        application = create!(
          host: host,
          errata_ids: errata_ids,
          task: task,
          user: user,
          applied_at: applied_at,
          status: status
        )
        [application]
      rescue ActiveRecord::RecordInvalid => e
        if e.record.errors.of_kind?(:task_id, :taken)
          Rails.logger.warn("Skipped duplicate errata application: task=#{task.id}, host=#{host.name}")
          []
        else
          raise
        end
      end
    end

    # Extract host ID from task input
    def self.extract_host_id_from_task(task)
      input = task.input
      return nil unless input

      if input['host'].is_a?(Hash)
        input['host']['id']
      elsif input['host_id']
        input['host_id']
      end
    end

    # Extract errata IDs from task
    def self.extract_errata_ids_from_task(task)
      input = task.input
      return [] unless input

      errata = input['errata'] || input['content']
      return errata if errata.present?

      return [] unless task.template_invocation

      if input['job_features']&.include?('katello_errata_install_by_search')
        extract_from_script(task)
      else
        extract_from_template_input(task)
      end
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
      ::TemplateInvocationInputValue
        .joins(:template_input)
        .where(template_invocation_id: task.template_invocation.id)
        .where("template_inputs.name = ?", 'errata')
        .first&.value&.split(',') || []
    end

    # Determine application status from task and action
    def self.determine_status(task, action)
      if task.result.present? && task.result != 'pending'
        task.result.to_s
      elsif action
        action.error.present? ? 'error' : 'success'
      else
        'success'
      end
    end
  end
end
