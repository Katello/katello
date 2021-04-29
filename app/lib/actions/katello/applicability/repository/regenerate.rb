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
            host_ids = ::Katello::Repository.find(input[:repo_id]).hosts_with_applicability.pluck(:id)
            return if host_ids.empty?
            ::Katello::Host::ContentFacet.trigger_applicability_generation(host_ids)
          end

          def humanized_name
            _("Generate repository applicability")
          end
        end
      end
    end
  end
end
