module Actions
  module Pulp3
    module Repository
      class Repair < Pulp3::AbstractAsyncTask
        include Helpers::Presenter
        def plan(repository_id, smart_proxy = SmartProxy.pulp_primary)
          plan_self(:repository_id => repository_id, :smart_proxy_id => smart_proxy.id)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          output[:response] = repo.backend_service(smart_proxy).repair(repo.version_href)
        end

        def run_progress
          presenter.progress
        end

        def run_progress_weight
          10
        end

        def presenter
          Presenters::RepairPresenter.new(self)
        end

        def rescue_strategy_for_self
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
