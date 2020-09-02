module Actions
  module Pulp
    module Repository
      class Create < Pulp::Abstract
        include Helpers::Presenter

        input_format do
          param :repository_id
          param :capsule_id
        end

        def plan(repository, smart_proxy = SmartProxy.pulp_primary!)
          if repository.is_a?(::Katello::ContentViewPuppetEnvironment)
            plan_self(:content_view_puppet_environment_id => repository.id, :capsule_id => smart_proxy.id)
          else
            plan_self(:repository_id => repository.id, :capsule_id => smart_proxy.id)
          end
        end

        def run
          if input[:repository_id]
            repo = ::Katello::Repository.find(input[:repository_id])
          else
            repo = ::Katello::ContentViewPuppetEnvironment.find(input[:content_view_puppet_environment_id]).nonpersisted_repository
          end
          output[:response] = repo.backend_service(smart_proxy(input[:capsule_id])).create
        rescue RestClient::Conflict
          Rails.logger.warn("Tried to add repository #{input[:pulp_id]} that already exists.")
          []
        end
      end
    end
  end
end
