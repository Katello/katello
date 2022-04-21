module Katello
  class PurposeStatus < HostStatus::Status
    UNKNOWN = 0
    MISMATCHED = 1
    MATCHED = 2
    NOT_SPECIFIED = 3

    def self.status_map
      map = {
        mismatched: MISMATCHED,
        matched: MATCHED,
        not_specified: NOT_SPECIFIED
      }

      map.default = UNKNOWN
      map
    end

    def self.status_name
      N_('System purpose')
    end

    def self.humanized_name
      'purpose'
    end

    def self.to_label(status)
      case status
      when MATCHED
        N_('Matched')
      when MISMATCHED
        N_('Mismatched')
      when NOT_SPECIFIED
        N_('Not specified')
      else
        N_('Unknown')
      end
    end

    def self.to_status(status, purpose_method, options)
      return UNKNOWN unless status.relevant?

      if options.key?(:status_override)
        return self.status_map[options[:status_override]]
      end

      consumer = status.host.subscription_facet.candlepin_consumer
      self.status_map[consumer.system_purpose.send(purpose_method)]
    end

    def to_label(_options = {})
      self.class.to_label(status)
    end

    def to_global(_options = {})
      if [MATCHED, UNKNOWN, NOT_SPECIFIED].include?(status)
        ::HostStatus::Global::OK
      else
        ::HostStatus::Global::WARN
      end
    end

    def to_status(options = {})
      self.class.to_status(self, :overall_status, options)
    end

    def relevant?(_options = {})
      host.subscription_facet.try(:uuid)
    end
  end
end
