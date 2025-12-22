module Actions
  module Katello
    module ContentView
      class AutoPublish < Actions::ActionWithSubPlans
        def plan(content_view, options)
          plan_self(content_view_id: content_view.id,
            description: options[:description],
            triggered_by: options[:triggered_by])
        end

        def total_count
          1
        end

        def content_view_locks
          ForemanTasks::Lock.where(
            resource_id: input[:content_view_id],
            resource_type: ::Katello::ContentView.to_s)
        end

        def create_sub_plans
          if content_view_locks.any?
            Rails.logger.info "Locks found, sleeping"
            try_again_later
          else
            begin
              trigger(Publish, ::Katello::ContentView.find(input[:content_view_id]))
            rescue ForemanTasks::Lock::LockConflict
              Rails.logger.info "Got a lock conflict"
              try_again_later
            end
          end
        end

        private

        def try_again_later
          output.delete(:total_count) # call initiate instead of resume in WithSubPlans
          plan_event(nil, polling_interval)
          suspend
        end
      end
    end
  end
end
