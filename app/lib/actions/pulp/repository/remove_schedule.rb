module Actions
  module Pulp
    module Repository
      class RemoveSchedule < Pulp::Abstract
        input_format do
          param :repo_id
        end

        def run
          repo = ::Katello::Repository.find(input[:repo_id])
          output[:response] = repo.sync_schedule(nil)
        end
      end
    end
  end
end
