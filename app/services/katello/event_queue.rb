module Katello
  class EventQueue
    @event_types = {}

    def self.clear_events(event_type, object_id, on_or_earlier_than)
      Katello::Event.where(:in_progress => true, :object_id => object_id, :event_type => event_type).where('created_at <= ?', on_or_earlier_than).delete_all
    end

    def self.next_event
      first = Katello::Event.where(:in_progress => false).order(:created_at => 'asc').first
      return if first.nil?
      last = ::Katello::Event.where(:in_progress => false, :object_id => first.object_id,
                                    :event_type => first.event_type).order(:created_at => 'desc').first
      mark_in_progress(first)
      last
    end

    def self.mark_in_progress(event)
      ::Katello::Event.where(:in_progress => false, :object_id => event.object_id, :event_type => event.event_type).
                       update_all(:in_progress => true)
    end

    def self.reset_in_progress
      Katello::Event.where(:in_progress => true).update_all(:in_progress => false)
    end

    def self.push_event(event_type, id)
      Event.create!(:event_type => event_type, :object_id => id)
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
