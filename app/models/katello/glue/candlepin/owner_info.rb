module Katello
  class Glue::Candlepin::OwnerInfo
    def initialize(organization)
      @info = Resources::Candlepin::OwnerInfo.find(organization.label)
    end

    def total_consumers
      @info['consumerCounts']['system']
    end

    def total_invalid_compliance_consumers
      i = @info['consumerCountsByComplianceStatus']['invalid'] ||= 0
      f = @info['consumerCountsByComplianceStatus']['false'] ||= 0
      return i + f
    end

    def total_valid_compliance_consumers
      # Systems that are hand-created (eg. through "New System" button) are by definition green.
      # To account for this, simply take the total count and subtract the red and yellow counts.
      #v = @info['consumerCountsByComplianceStatus']['valid'] ||= 0
      #t = @info['consumerCountsByComplianceStatus']['true'] ||= 0

      return self.total_consumers - self.total_invalid_compliance_consumers - self.total_partial_compliance_consumers
    end

    def total_partial_compliance_consumers
      @info['consumerCountsByComplianceStatus']['partial'] ||= 0
    end

    private

    def find_value(set_key, value_type, entry_type)
      @info[set_key].each do |hash|
        if hash['valueType'] == value_type && hash['entryType'] == entry_type
          return hash['value']
        end
      end
      nil
    end
  end
end
