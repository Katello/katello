module Katello
  class ErrataApplication < Katello::Model
    belongs_to :host, class_name: '::Host::Managed', inverse_of: :errata_applications
    belongs_to :erratum, class_name: 'Katello::Erratum', inverse_of: :errata_applications
    belongs_to :task, class_name: 'ForemanTasks::Task', optional: true, inverse_of: false
    belongs_to :user, class_name: '::User', optional: true

    validates :host, :erratum, :applied_at, :status, :method, presence: true
    validates :status, inclusion: { in: %w[success error warning cancelled] }
    validates :method, inclusion: { in: %w[remote_execution katello_agent manual] }

    scope :successful, -> { where(status: 'success') }
    scope :failed, -> { where(status: %w[error warning cancelled]) }
    scope :for_host, ->(host) { where(host: host) }
    scope :for_erratum, ->(erratum) { where(erratum: erratum) }
    scope :since, ->(date) { where('applied_at >= ?', date) }
    scope :up_to, ->(date) { where('applied_at <= ?', date) }
    scope :by_method, ->(method) { where(method: method) }

    default_scope { order(applied_at: :desc) }

    validates :erratum_id, uniqueness: { scope: [:host_id, :applied_at] }

    # Record errata applications from a completed task
    # @param task [ForemanTasks::Task] The completed task
    # @param action [Dynflow::Action] Optional action object
    # @return [Array<ErrataApplication>] Created application records
    def self.record_from_task(task, action = nil)
      return [] unless task
      return [] unless task.state == 'stopped'

      host_id = extract_host_id_from_task(task)
      return [] unless host_id

      host = ::Host::Managed.find_by(id: host_id)
      return [] unless host

      errata_ids = extract_errata_ids_from_task(task)
      return [] if errata_ids.blank?

      errata = Katello::Erratum.where(errata_id: errata_ids)
      status = determine_status(task, action)
      applied_at = task.ended_at || Time.zone.now
      method = determine_method_from_task(task)
      user = task.user

      results = errata.map do |erratum|
        begin
          create!(
            host: host,
            erratum: erratum,
            task: task,
            user: user,
            applied_at: applied_at,
            status: status,
            method: method
          )
        rescue ActiveRecord::RecordInvalid => e
          if e.record.errors.of_kind?(:erratum_id, :taken)
            Rails.logger.warn("Skipped duplicate errata application: erratum=#{erratum.errata_id}, host=#{host.name}, task=#{task.id}")
            nil
          else
            raise
          end
        end
      end
      results.compact
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

    # Determine application method from task
    def self.determine_method_from_task(task)
      if task.label == 'Actions::RemoteExecution::RunHostJob'
        'remote_execution'
      elsif task.label.to_s.include?('Katello::Host::Erratum')
        'katello_agent'
      else
        'remote_execution'
      end
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
