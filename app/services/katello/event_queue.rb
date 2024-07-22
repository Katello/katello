module Katello
  class EventQueue
    MAX_RETRY_AGE = 6.hours

    @event_types = {}

    def self.create_instance(event)
      event_class = ::Katello::EventQueue.event_class(event.event_type)

      event_class.new(event.object_id) do |instance|
        instance.metadata = event.metadata if event.metadata
      end
    end

    def self.queue_depth
      ::Katello::Event.all.size
    end

    def self.runnable_events
      Katello::Event.where(process_after: nil).or(Katello::Event.where(process_after: Date.new..Time.zone.now))
    end

    def self.clear_events(event_type, object_id, on_or_earlier_than)
      Katello::Event.where(:in_progress => true, :object_id => object_id, :event_type => event_type).where('created_at <= ?', on_or_earlier_than).delete_all
    end

    def self.next_event
      first = runnable_events.where(:in_progress => false).order(:created_at => 'asc').first
      return if first.nil?
      last = runnable_events.where(:in_progress => false, :object_id => first.object_id,
                                    :event_type => first.event_type).order(:created_at => 'desc').first
      mark_in_progress(first)
      last
    end

    def self.mark_in_progress(event)
      query = ::Katello::Event.where(
        in_progress: false,
        object_id: event.object_id,
        event_type: event.event_type
      )

      # Don't mark future events as in progress!
      query = query.where('process_after <= ?', event.process_after) if event.process_after

      query.update_all(in_progress: true)
    end

    def self.reset_in_progress
      Katello::Event.where(:in_progress => true).update_all(:in_progress => false)
    end

    def self.push_event(event_type, id)
      attrs = {
        event_type: event_type,
        object_id: id,
      }

      yield(attrs) if block_given?

      Event.create!(attrs)
    end

    def self.reschedule_event(event)
      return :expired if event.created_at <= MAX_RETRY_AGE.ago

      retry_seconds = event_class(event.event_type).try(:retry_seconds)
      if retry_seconds
        Katello::Event.update(event.id, in_progress: false, process_after: Time.zone.now + retry_seconds)
      end
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
