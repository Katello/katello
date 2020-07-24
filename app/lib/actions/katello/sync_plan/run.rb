module Actions
  module Katello
    module SyncPlan
      class Run < Actions::EntryAction
        include Actions::RecurringAction

        middleware.use Actions::Middleware::RecurringLogic

        def delay(delay_options, sync_plan)
          input.update :sync_plan_name => sync_plan.name
          add_missing_task_group(sync_plan)
          super delay_options, sync_plan
        end

        def plan(sync_plan)
          add_missing_task_group(sync_plan)
          action_subject(sync_plan)
          User.as_anonymous_admin do
            syncable_products = sync_plan.products.syncable
            syncable_roots = ::Katello::RootRepository.where(:product_id => syncable_products).has_url

            plan_action(::Actions::BulkAction, ::Actions::Katello::Repository::Sync, syncable_roots.map(&:library_instance).compact) unless syncable_roots.empty?
            plan_self(:sync_plan_name => sync_plan.name)
          end
        end

        def add_missing_task_group(sync_plan)
          if sync_plan.task_group.nil?
            sync_plan.task_group = ::Katello::SyncPlanTaskGroup.create!
            sync_plan.save!
          end
          task.add_missing_task_groups(sync_plan.task_group)
        end

        def humanized_name
          _('Run Sync Plan:')
        end

        def humanized_input
          input.fetch(:sync_plan_name, _('Unknown'))
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
