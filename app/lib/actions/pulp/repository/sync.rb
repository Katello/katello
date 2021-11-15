module Actions
  module Pulp
    module Repository
      class Sync < Pulp::AbstractAsyncTask
        include Helpers::Presenter

        input_format do
          param :repo_id
          param :source_url # allow overriding the feed URL
          param :options # Pulp sync options
        end

        def invoke_external_task
          overrides = {}
          overrides[:feed] = input[:source_url] if input[:source_url]
          overrides[:validate] = !(SETTINGS[:katello][:pulp][:skip_checksum_validation])
          overrides.merge(input[:options]) if input[:options]
          repo = ::Katello::Repository.find(input[:repo_id])

          output[:pulp_tasks] = repo.backend_service(::SmartProxy.pulp_primary).sync(overrides)
        end

        def finalize
          check_error_details
        end

        def external_task=(tasks)
          output[:contents_changed] = contents_changed?(tasks)
          super
        end

        def check_error_details
          output[:pulp_tasks].each do |pulp_task|
            error_details = pulp_task.try(:[], "progress_report").try(:[], "yum_importer").try(:[], "content").try(:[], "error_details")
            if error_details && error_details[0]
              fail _("An error occurred during the sync \n%{error_message}") % {:error_message => error_details[0]}
            end
          end
        end

        def contents_changed?(tasks)
          if tasks.is_a?(Hash)
            # note: for syncs initiated by a sync plan, tasks is a hash input
            sync_task = tasks
          else
            sync_task = tasks.find { |task| (task['tags'] || []).include?('pulp:action:sync') }
          end

          if sync_task && sync_task['state'] == 'finished' && sync_task[:result]
            if sync_task['result']['added_count'] > 0 || sync_task['result']['removed_count'] > 0 || sync_task['result']['updated_count'] > 0
              true
            else
              repo = ::Katello::Repository.find_by(:pulp_id => sync_task['result']['repo_id'])
              repo ? repo.pulp_counts_differ? : true
            end
          else
            true #if we can't figure it out, assume something changed
          end
        end

        def run_progress
          presenter.progress
        end

        def run_progress_weight
          10
        end

        def presenter
          repo = ::Katello::Repository.find(input['repo_id']) if input['repo_id']
          # For repo sync tasks older than katello 3.14, we only have pulp_id available in input.
          repo ||= ::Katello::Repository.where(:pulp_id => input['pulp_id']).first if input['pulp_id']

          if repo.try(:yum?)
            Presenters::YumPresenter.new(self)
          elsif repo.try(:file?)
            Presenters::FileUnitPresenter.new(self)
          elsif repo.try(:docker?)
            Presenters::DockerPresenter.new(self)
          elsif repo.try(:deb?)
            Presenters::DebPresenter.new(self)
          end
        end

        def rescue_strategy_for_self
          # There are various reasons the syncing fails, not all of them are
          # fatal: when fail on syncing, we continue with the task ending up
          # in the warning state, but not locking further syncs
          Dynflow::Action::Rescue::Skip
        end

        def ignored_tags
          # ignore background download tasks
          ["pulp:action:download"]
        end
      end
    end
  end
end
