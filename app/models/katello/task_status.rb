module Katello
  class TaskStatus < Katello::Model
    include Util::TaskStatus

    serialize :result
    serialize :progress
    serialize :parameters, Hash
    class Status
      WAITING = :waiting
      RUNNING = :running
      ERROR = :error
      FINISHED = :finished
      CANCELED = :canceled
      TIMED_OUT = :timed_out
    end

    belongs_to :organization, :inverse_of => :task_statuses, :class_name => "Organization"
    belongs_to :user, :inverse_of => :task_statuses, :class_name => "::User"

    belongs_to :task_owner, :polymorphic => true

    # needed to delete providers w/ task status
    has_one :provider, :class_name => "Katello::Provider", :dependent => :nullify

    validates_lengths_from_database
    before_save :setup_task_type

    before_save do |status|
      unless status.user
        status.user = User.current
      end
    end

    # log error to the rails log
    before_save do |status|
      if status.state_changed?
        begin
          if status.state == TaskStatus::Status::ERROR.to_s
            Rails.logger.error "Task #{status.task_type} (#{status.id}) is in error state"
            Rails.logger.debug "Task parameters: #{status.parameters.inspect.to_s[0, 255]}, result: #{status.result.inspect.to_s[0, 255]}"
          else
            Rails.logger.debug "Task #{status.task_type} (#{status.id}) #{status.state}" if status.id
          end
          return true
        rescue
          Rails.logger.debug "Unable to report status change" # minor error
          # if logger level is higher than debug logger return false that would cause rollback
          # since this is log only callback we must be sure to return true
          true
        end
      end
    end

    def initialize(attrs = nil, _options = {})
      unless attrs.nil?
        # only keep keys for which we have db columns
        attrs = attrs.reject do |k, _v|
          !self.class.column_defaults.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
        end
      end

      super(attrs)
    end

    def overall_status
      # the overall status of tasks (e.g. associated with a system) are determined by a
      # combination of the task state and the status of the unit within the task.
      unit_status = true
      if (self.result.is_a? Hash) && (self.result.key? :details)
        if self.result[:details].key? :rpm
          unit_status = self.result[:details][:rpm][:succeeded]
        elsif self.result[:details].key? :package_group
          unit_status = self.result[:details][:package_group][:succeeded]
        end
      end

      (self.state.to_s == "error" || !unit_status) ? "error" : self.state
    end

    def pending?
      self.state.to_s == "waiting" || self.state.to_s == "running"
    end

    def finished?
      ((self.state != TaskStatus::Status::WAITING.to_s) && (self.state != TaskStatus::Status::RUNNING.to_s))
    end

    def canceled?
      self.state == TaskStatus::Status::CANCELED.to_s
    end

    def error?
      (self.state == TaskStatus::Status::ERROR.to_s)
    end

    def refresh
      self
    end

    def merge_pulp_task!(pulp_task)
      PulpTaskStatus.dump_state(pulp_task, self)
    end

    def human_readable_message
      task_template = TaskStatus::TYPES[self.task_type]
      return '' if task_template.nil?
      if task_template[:user_message]
        task_template[:user_message] % self.user.login
      else
        task_template[:english_name]
      end
    end

    def pending_message
      # Retrieve a text message that may be rendered for a 'pending' task's status.  This is used in various places,
      # such as System Event history.
      details = TaskStatus::TYPES[self.task_type]
      case details[:type]
      when :package
        p = self.parameters[:packages]
        unless p && p.length > 0
          if self.task_type == "package_update"
            return _("all packages")
          end
          return ""
        end
        if p.length == 1
          return p.first
        else
          return _("%{package} (%{total} other packages)") % {:package => p.first, :total => p.length - 1}
        end
      when :package_group
        p = self.parameters[:groups]
        if p.length == 1
          return p.first
        else
          return _("%{group} (%{total} other package groups)") % {:group => p.first, :total => p.length - 1}
        end
      when :errata
        p = self.parameters[:errata_ids]
        if p.length == 1
          return p.first
        else
          return _("%{errata} (%{total} other errata)") % {:errata => p.first, :total => p.length - 1}
        end
      end
    end

    # TODO: break up method
    # rubocop:disable Metrics/MethodLength
    def message
      # Retrieve a text message that may be rendered for a task's status.  This is used in various places,
      # such as System Event history.
      details = TaskStatus::TYPES[self.task_type]
      return _("Non-system event") if details.nil?

      case details[:type]
      when :package
        p = self.parameters[:packages]
        first_package = p.first.is_a?(Hash) ? p.first[:name] : p.first
        unless p && p.length > 0
          if self.task_type == "package_update"
            case self.overall_status
            when "running"
              return "updating"
            when "waiting"
              return "updating"
            when "error"
              return _("all packages update failed")
            else
              return _("all packages update")
            end
          end
        end

        msg = details[:event_messages][self.overall_status]
        return n_(msg[1], msg[2], p.length) % { package: first_package, total: p.length - 1 }
      when :candlepin_event
        return self.result
      when :package_group
        p = self.parameters[:groups]
        msg = details[:event_messages][self.overall_status]
        return n_(msg[1], msg[2], p.length) % { group: p.first, total: p.length - 1 }
      when :errata
        p = self.parameters[:errata_ids]
        msg = details[:event_messages][self.overall_status]
        return n_(msg[1], msg[2], p.length) % { errata: p.first, total: p.length - 1 }
      end
    end

    def humanize_type
      TaskStatus::TYPES[self.task_type][:name]
    end

    def humanize_parameters
      humanized_parameters = []
      if (packages = self.parameters[:packages])
        humanized_parameters.concat(packages)
      end
      if (groups = self.parameters[:groups])
        humanized_parameters.concat(groups.map { |g| g =~ /^@/ ? g : "@#{g}" })
      end
      if (errata = self.parameters[:errata_ids])
        humanized_parameters.concat(errata)
      end
      humanized_parameters.join(", ")
    end

    def description
      ret = ""
      ret << humanize_type << ": "
      ret << humanize_parameters
    end

    def result_description
      case self.state.to_s
      when "finished"
        # tasks initiated by pulp to the system can have state=finished
        # when the request is fully successful (e.g. all packages installed)
        # as well as if the task is not fully successful (e.g. attempt to
        # install a pkg that does not exist)
        generate_description
      when "error"
        # tasks initiated by pulp to the system will only have state=error
        # if an exception is thrown from the system/agent during remote
        # method invocation
        rmi_error_description
      else ""
      end
    end

    def generate_description
      ret = []
      task_type = self.task_type.to_s

      if task_type =~ /^package_group/
        action = task_type.include?("remove") ? :removed : :installed
        ret = packages_change_description(result[:details][:package_group], action)
      elsif task_type == "package_install" || task_type == "errata_install"
        ret = packages_change_description(result[:details][:rpm], :installed)
      elsif task_type == "package_update"
        ret = packages_change_description(result[:details][:rpm], :updated)
      elsif task_type == "package_remove"
        ret = packages_change_description(result[:details][:rpm], :removed)
      end
      ret
    end

    def rmi_error_description
      errors, stacktrace = self.result[:errors]
      return "" unless errors
      # Handle not very friendly Pulp message
      if errors =~ /^\(.*\)$/
        if stacktrace.class == Array
          stacktrace.last.split(":").first
        else
          stacktrace.split("(").first
        end
      elsif errors =~ /^\[.*,.*\]$/m
        result = errors.split(",").map do |error|
          error.gsub(/^\W+|\W+$/, "")
        end
        result.join("\n")
      else
        errors
      end
    rescue
      if self.result.is_a? Hash
        self.result[:errors].join(' ').to_s
      else
        self.result
      end
    end

    protected

    def setup_task_type
      unless self.task_type
        self.task_type = self.class.name
      end
    end

    def packages_change_description(data, action)
      ret = []

      data ||= {}
      data[:details] ||= {}
      data[:details][:resolved] ||= []
      data[:details][:deps] ||= []

      packages = data[:details][:resolved] + data[:details][:deps]
      if packages.empty?
        case action
        when :updated
          ret << _("No packages updated")
        when :removed
          ret << _("No packages removed")
        else
          ret << _("No new packages installed")
        end
      else
        if data[:succeeded]
          ret = packages.map do |package_attrs|
            package_attrs[:qname]
          end
        else
          ret << data[:details][:message]
        end
      end
      ret.sort
    end
  end
end
