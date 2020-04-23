module Actions
  module Katello
    module Applicability
      module Hosts
        class Generate < Actions::EntryAction
          input_format do
            param :host_ids, Array
          end

          def run
            input[:host_ids].each do |host_id|
              ::Katello::EventQueue.push_event(::Katello::Events::GenerateHostApplicability::EVENT_TYPE, host_id)
            end
          end

          def humanized_name
            _("Bulk generate applicability for hosts")
          end
        end
      end
    end
  end
end
