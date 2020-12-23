module Actions
  module Candlepin
    module Consumer
      class RegenerateEntitlementCertificates < Candlepin::Abstract
        include ActionView::Helpers::TextHelper

        input_format do
          param :uuids, Array
        end

        def plan(uuids, org_label)
          Rails.logger.info("Marking entitlement certs dirty for #{pluralize(uuids.length, 'client')}")
          sequence do
            uuids.compact.uniq.in_groups_of(10, false) do |uuid_group|
              plan_action(::Actions::Candlepin::Consumer::RegenerateEntitlementCertificateBatch, uuid_group)
            end
          end

          plan_self(
            uuids: uuids,
            org_label: org_label
          )
        end

        def finalize
          output[:result] = "#{pluralize(input[:uuids].length, 'entitlement certificate')} marked dirty"
        end

        def humanized_name
          "Regenerate entitlement certificates"
        end

      end

      class RegenerateEntitlementCertificateBatch < Candlepin::Abstract
        input_format do
          param :uuids, Array
        end

        def plan(uuids)
          if uuids.is_a?(String)
            raise ::ArgumentError, "Must pass in an array of uuids, not a string"
          end
          if uuids.length > 10
            raise ::ArgumentError, "#{self.class} can only accept 10 uuids at a time: #{uuids}"
          end
          plan_self(uuids: uuids)
        end

        def run
          results = []
          input[:uuids].each do |uuid|
            result = ::Katello::Candlepin::Consumer.new(uuid, input[:org_label]).regenerate_entitlement_certificates
            results << { uuid => result }
          end
          output[:results] = results
        end

        def humanized_name
          "Regenerate entitlement certificates for consumer"
        end
      end
    end
  end
end
