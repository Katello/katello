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
      event_class.trigger(*args)
    rescue => e
      ::Logging.logger['glue'].error("#{e.class}: #{e.message}")
      ::Logging.logger['glue'].error("#{e.response}") if e.respond_to? :response
      ::Logging.logger['glue'].error(e.backtrace.join("\n"))
    end
  end
end
