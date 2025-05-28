module Actions
  module Katello
    module ContentView
      class CapsuleSync < Actions::Base
        def humanized_name
          _("Sync Content View on Smart Proxy(ies)")
        end

        def plan(content_view, environment)
          env_smart_proxies = SmartProxy.unscoped.with_environment(environment)
          smart_proxies = env_smart_proxies.select { |sp| sp.authorized?(:manage_capsule_content) && sp.authorized?(:view_capsule_content) }
          sequence do
            concurrence do
              unless smart_proxies.blank?
                plan_action(::Actions::BulkAction, ::Actions::Katello::CapsuleContent::Sync, smart_proxies.sort,
                            :content_view_id => content_view.id, :environment_id => environment.id, :skip_content_counts_update => true)
              end
            end
            #For Content view triggered capsule sync, we need to update content counts in one action in finalize, instead of one action per CV, per env, per smart proxy
            plan_self(:content_view_id => content_view.id, :environment_id => environment.id, skipped_capsules: (env_smart_proxies - smart_proxies).any?)
          end
        end

        def finalize
          environment = ::Katello::KTEnvironment.find(input[:environment_id])
          if input[:skipped_capsules]
            output[:warning] = "Some smart proxies are not authorized for capsule content management or viewing in environment '#{environment.name}'. Skipping sync for those smart proxies."
            Rails.logger.warn output[:warning]
          end
          if Setting[:automatic_content_count_updates]
            smart_proxies = SmartProxy.unscoped.with_environment(environment).select { |sp| sp.authorized?(:manage_capsule_content) && sp.authorized?(:view_capsule_content) }
            options = {environment_id: input[:environment_id], content_view_id: input[:content_view_id]}
            smart_proxies.each do |smart_proxy|
              ::ForemanTasks.async_task(::Actions::Katello::CapsuleContent::UpdateContentCounts, smart_proxy, options)
            end
          else
            Rails.logger.info "Skipping content counts update as automatic content count updates are disabled. To enable automatic content count updates, set the 'automatic_content_count_updates' setting to true.
To update content counts manually, run the 'Update Content Counts' action."
          end
        end
      end
    end
  end
end
