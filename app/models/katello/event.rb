module Katello
  class Event < Katello::Model
    validate :validate_event_type

    def validate_event_type
      unless EventQueue.supported_event_types.include?(self.event_type)
        errors.add(:event_type, _("Unsupported event type %{type}. Supported: %{types}") %
            {:type => self.event_type, :types => EventQueue.supported_event_types.join(',')})
      end
    end
  end
end
