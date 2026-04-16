module Actions
  module Katello
    module Applicability
      class Scheduler < Actions::Base
        include Dynflow::Action::Singleton
        include Dynflow::Action::Polling

        def queue
          ::Katello::HOST_TASKS_QUEUE
        end

        def run(event = nil)
          case event
          when Skip
            # noop
          else
            super
          end
        end

        def invoke_external_task
        end

        def poll_external_task
          ::Katello::Applicability::Scheduler.drain_loop
          output[:done] = true
        rescue => e
          output[:last_error] = e
          Rails.logger.error "[applicability] #{e}"
        end

        def done?
          output[:done] == true
        end

        def rescue_strategy
          # Release singleton lock on error
          Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          _("Host applicability scheduler")
        end
      end
    end
  end
end
