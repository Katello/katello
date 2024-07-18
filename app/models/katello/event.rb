module Katello
  class Event < Katello::Model
    validate :validate_event_type
    # NOTE: Do not use active record call backs or dependent references on this class
    # Direct deletes are made in EventQueue#clear_events (instead of destroys).

    serialize :metadata, Hash

    def validate_event_type
      unless EventQueue.supported_event_types.include?(self.event_type)
        errors.add(:event_type, _("Unsupported event type %{type}. Supported: %{types}") %
            {:type => self.event_type, :types => EventQueue.supported_event_types.join(',')})
      end
    end
  end
end
