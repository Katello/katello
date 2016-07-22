module Actions
  module Katello
    module Repository
      class ImportApplicability < Actions::Base
        middleware.use Actions::Middleware::ExecuteIfContentsChanged

        input_format do
          param :repo_id
          param :contents_changed
        end

        def run
          repo = ::Katello::Repository.find(input[:repo_id])
          repo.import_host_applicability
        end

        def rescue_strategy_for_self
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
