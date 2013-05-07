module Glue
  # triggering events on model creation/deletion for better
  # extendability
  module Event

    def self.included(base)
      base.class_eval do
        after_create :trigger_create_event
        before_destroy :trigger_destroy_event
      end
    end

    def trigger_create_event
      Glue::Event.trigger(create_event, self) if create_event
    end

    def trigger_destroy_event
      Glue::Event.trigger(destroy_event, self) if destroy_event
    end

    # define the Dynflow action to be triggered after create
    def create_event
    end

    # define the Dynflow action to be triggered before destroy
    def destroy_event
    end

    def self.trigger(event_class, *args)
      execution_plan = event_class.trigger(*args)
      failed = false
      execution_plan.failed_steps.each do |step|
        Notify.warning(_("Failed to perform additional action %{action}: %{message}") %
                       { :action => step.action_class.name,
                         :message => step.error['message'] },
                       { :asynchronous => true, :persist => true })
        failed = true
      end

      log_message = execution_plan.steps.map do |step|
        message = "#{step.action_class.name}:#{step.status}:#{step.input.inspect} -> #{step.output.inspect}"
        if step.status == 'error'
          message << "#{step.error['exception']}: #{step.error['message']}\n"
          message << step.error['backtrace'].join("\n")
        end
          message
      end.join("\n")

      if failed
        ::Logging.logger['glue'].error(log_message)
      else
        ::Logging.logger['glue'].debug(log_message)
      end
    end
  end
end
