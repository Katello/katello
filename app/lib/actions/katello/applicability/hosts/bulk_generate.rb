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
              content_facet = ::Host.find(host_id).content_facet
              content_facet.calculate_and_import_applicability
            end
          end

          def queue
            ::Katello::HOST_TASKS_QUEUE
          end

          def resource_locks
            :link
          end

          def humanized_name
            _("Bulk generate applicability for hosts")
          end
        end
      end
    end
  end
end
