module Katello
  module Candlepin
    class SystemPurpose
      attr_reader :compliance

      # the purpose compliance of a consumer and via event queue
      # are in the same format so we can parse them identically
      def initialize(purpose_compliance)
        @compliance = purpose_compliance
      end

      def overall_status
        if compliance['status'] == 'not specified'
          :not_specified
        elsif compliance['status'] == 'matched'
          :matched
        elsif compliance['status'] == 'mismatched'
          :mismatched
        end
      end

      def sla_status
        purpose_status(compliance['compliantSLA'], compliance['nonCompliantSLA'])
      end

      def role_status
        purpose_status(compliance['compliantRole'], compliance['nonCompliantRole'])
      end

      def usage_status
        purpose_status(compliance['compliantUsage'], compliance['nonCompliantUsage'])
      end

      def addons_status
        purpose_status(compliance['compliantAddons'], compliance['nonCompliantAddons'])
      end

      def purpose_status(compliant, noncompliant)
        if (noncompliant.nil? || noncompliant.try(:empty?)) && compliant.empty?
          :not_specified
        elsif noncompliant.nil? || noncompliant.try(:empty?)
          :matched
        elsif noncompliant.present?
          :mismatched
        end
      end
    end
  end
end
