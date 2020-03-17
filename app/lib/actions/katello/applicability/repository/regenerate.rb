module Actions
  module Katello
    module Applicability
      module Repository
        class Regenerate < Actions::EntryAction
          middleware.use Actions::Middleware::ExecuteIfContentsChanged

          input_format do
            param :repo_id, Integer
            param :contents_changed
          end

          def run
            ::Katello::Repository.find(input[:repo_id]).content_facets.each do |facet|
              ::Katello::EventQueue.push_event(::Katello::Events::GenerateHostApplicability::EVENT_TYPE, facet.host.id)
            end
          end

          def humanized_name
            _("Generate repository applicability")
          end
        end
      end
    end
  end
end
