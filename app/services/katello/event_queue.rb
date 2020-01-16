module Katello
  class EventQueue
    @event_types = {}

    def self.client
      Katello::Messaging::Connection.for_client('katello_event_queue')
    end

    def self.create_instance(event)
      event_class = ::Katello::EventQueue.event_class(event.event_type)

      event_class.new(event.object_id) do |instance|
        instance.metadata = event.metadata if event.metadata
      end
    end

    def self.push_event(event_type, object_id, payload = '')
      attrs = {
        katello_event_type: event_type,
        katello_object_id: object_id,
        _AMQ_LVQ_NAME: "#{event_type}#{object_id}"
      }

      client.publish('katello.katello', payload, attrs)
    end

    def self.register_event(event_type, klass)
      @event_types[event_type] = klass.name
    end

    def self.supported_event_types
      @event_types.keys
    end

    def self.event_class(event_type)
      fail _("Invalid event_type %s") % event_type if @event_types[event_type].nil?
      @event_types[event_type].constantize
    end
  end
end
