module Actions
  module Pulp
    module Repository
      class Sync < Pulp::AbstractAsyncTask
        include Helpers::Presenter

        input_format do
          param :pulp_id
          param :task_id # In case we need just pair this action with existing sync task
        end

        def invoke_external_task
          if input[:task_id]
            # don't initiate, just load the existing task
            task_resource.poll(input[:task_id])
          else
            sync_options = {}

            if ::Katello.config.pulp.sync_KBlimit
              # set bandwidth limit
              sync_options[:max_speed] ||= ::Katello.config.pulp.sync_KBlimit
            end
            if ::Katello.config.pulp.sync_threads
              # set threads per sync
              sync_options[:num_threads] ||= ::Katello.config.pulp.sync_threads
            end
            sync_options[:validate] = !(::Katello.config.pulp.skip_checksum_validation)

            output[:pulp_tasks] = pulp_tasks =
                pulp_resources.repository.sync(input[:pulp_id],  override_config: sync_options)
            pulp_tasks
          end
        end

        def run_progress
          presenter.progress
        end

        def run_progress_weight
          10
        end

        def presenter
          repo = ::Katello::Repository.where(:pulp_id => input['pulp_id']).first

          if repo.try(:puppet?)
            Presenters::PuppetPresenter.new(self)
          elsif repo.try(:yum?)
            Presenters::YumPresenter.new(self)
          elsif repo.try(:file?)
            Presenters::IsoPresenter.new(self)
          elsif repo.try(:docker?)
            Presenters::DockerPresenter.new(self)
          elsif repo.try(:ostree?)
            Presenters::OstreePresenter.new(self)
          end
        end

        def rescue_strategy_for_self
          # There are various reasons the syncing fails, not all of them are
          # fatal: when fail on syncing, we continue with the task ending up
          # in the warning state, but not locking further syncs
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
