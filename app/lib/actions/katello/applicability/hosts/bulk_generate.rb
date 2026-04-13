module Actions
  module Katello
    module Applicability
      module Hosts
        class BulkGenerate < Actions::Base
          input_format do
            param :host_ids, Array
          end

          def run
            error = false

            ::Katello::Host::ContentFacet.includes(:host).where(host_id: input[:host_ids]).find_each do |content_facet|
              content_facet.calculate_and_import_applicability
            rescue NoMethodError, PG::Error => e
              Rails.logger.error("Error calculating applicability for host #{content_facet.host_id}: #{e.message}")
              error = true
            end

            fail "Error calculating applicability for one or more hosts" if error
          end

          def rescue_strategy
            Dynflow::Action::Rescue::Skip
          end

          def queue
            ::Katello::HOST_TASKS_QUEUE
          end

          def hostname(host_id)
            content_facet = ::Katello::Host::ContentFacet.find_by_host_id(host_id)
            content_facet&.host&.name
          end

          def humanized_name
            if input && input[:host_ids]&.length == 1
              _("Bulk generate applicability for host %s" % hostname(input[:host_ids]&.first))
            else
              _("Bulk generate applicability for hosts")
            end
          end
        end
      end
    end
  end
end
