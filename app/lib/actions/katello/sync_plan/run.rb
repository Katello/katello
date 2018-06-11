module Actions
  module Katello
    module SyncPlan
      class Run < Actions::EntryAction
        include Actions::RecurringAction
        def plan(sync_plan)
          action_subject(sync_plan)
          User.as_anonymous_admin do
            syncable_products = sync_plan.products.syncable
            #fail _("Products = #{syncable_products}") if true
            syncable_repositories = ::Katello::Repository.where(:product_id => syncable_products).has_url

            fail _("No syncable repositories found for selected products and options.") if syncable_repositories.empty?
            syncable_repositories.each do |repo|
              plan_action(::Actions::Katello::Repository::Sync, repo)
            end
          end
        end

        def humanized_name
          _("Run Sync Plan")
        end

      end
    end
  end
end
