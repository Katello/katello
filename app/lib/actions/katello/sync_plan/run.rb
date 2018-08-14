module Actions
  module Katello
    module SyncPlan
      class Run < Actions::EntryAction
        include Actions::RecurringAction
        def plan(sync_plan)
          action_subject(sync_plan)
          User.as_anonymous_admin do
            fail _("No products in sync plan") unless sync_plan.products

            syncable_products = sync_plan.products.syncable
            syncable_repositories = ::Katello::Repository.where(:product_id => syncable_products).has_url

            fail _("No syncable repositories found for selected products and options.") if syncable_repositories.empty?

            plan_action(::Actions::BulkAction, ::Actions::Katello::Repository::Sync,
                        syncable_repositories)

            plan_self(:sync_plan_name => sync_plan.name)
          end
        end

        def humanized_name
          if input.try(:[], :sync_plan_name)
            _('Run Sync Plan %s') % (input[:sync_plan_name] || _('Unknown'))
          else
            _('Run Sync Plan')
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
