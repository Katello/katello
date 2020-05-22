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

            host_ids.each do |host_id|
              ::Katello::ApplicableHostQueue.push_host(host_id)
            end

            ::Katello::EventQueue.push_event(::Katello::Events::GenerateHostApplicability::EVENT_TYPE, 0)
          end

          def humanized_name
            _("Generate repository applicability")
          end
        end
      end
    end
  end
end
