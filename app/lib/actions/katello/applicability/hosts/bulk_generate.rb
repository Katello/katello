module Actions
  module Katello
    module Applicability
      module Hosts
        class BulkGenerate < Actions::EntryAction
          input_format do
            param :host_ids, Array
          end

          def run
            input[:host_ids].each do |host_id|
              content_facet = ::Katello::Host::ContentFacet.find_by_host_id(host_id)
              if content_facet.present?
                content_facet.calculate_and_import_applicability
              else
                Rails.logger.warn(_("Content Facet for host with id %s is non-existent. Skipping applicability calculation.") % host_id)
              end
            end
          end

          def queue
            ::Katello::HOST_TASKS_QUEUE
          end

          def resource_locks
            :link
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
