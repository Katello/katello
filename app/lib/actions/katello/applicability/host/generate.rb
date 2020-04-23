module Actions
  module Katello
    module Applicability
      module Host
        class Generate < Actions::EntryAction
          # This should be run through Katello::Events::GenerateHostApplicability

          input_format do
            param :host_id, Integer
          end

          def run
            content_facet = ::Host.find(input[:host_id]).content_facet
            content_facet.calculate_and_import_applicability
          end

          def resource_locks
            :link
          end

          def humanized_name
            _("Generate host applicability")
          end
        end
      end
    end
  end
end
