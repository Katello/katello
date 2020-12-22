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
            uuids.compact.uniq.each do |uuid|
              plan_action(::Actions::Candlepin::Consumer::RegenerateEntitlementCertificate, uuid)
            end
          end

          plan_self(
            uuids: uuids,
            org_label: org_label
          )
        end

        def humanized_name
          "Regenerate entitlement certificates"
        end

      end

      class RegenerateEntitlementCertificate < Candlepin::Abstract
        input_format do
          param :uuid, String
        end

        def plan(uuid)
          plan_self(uuid: uuid)
        end

        def run
          output[:result] = ::Katello::Candlepin::Consumer.new(input[:uuid], input[:org_label]).regenerate_entitlement_certificates
        end

        def humanized_name
          "Regenerate entitlement certificates for consumer"
        end
      end
    end
  end
end
