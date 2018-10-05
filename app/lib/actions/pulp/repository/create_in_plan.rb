module Actions
  module Pulp
    module Repository
      class CreateInPlan < Create
        alias_method :perform_run, :run

        def plan(repository)
          input[:response] = repository.backend_service(smart_proxy).create
        rescue RestClient::Conflict
          Rails.logger.warn("Tried to add repository #{input[:pulp_id]} that already exists.")
        end
      end
    end
  end
end
