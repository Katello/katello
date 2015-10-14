module Actions
  module Katello
    module System
      class AutoAttachSubscriptions < Actions::EntryAction
        include Helpers::Presenter
        middleware.use Actions::Middleware::KeepCurrentUser
        middleware.use ::Actions::Middleware::RemoteAction

        input_format do
          param :id, Integer
        end

        def plan(system)
          system.disable_auto_reindex!
          action_subject system
          sequence do
            autoattach_plan = plan_action(::Actions::Candlepin::Consumer::AutoAttachSubscriptions, system) if ::Katello.config.use_cp
            plan_self(:attached_subscriptions => autoattach_plan.output[:attached_subscriptions])
            plan_action(ElasticSearch::Reindex, system) if ::Katello.config.use_elasticsearch
          end
        end

        def run
          output[:attached_subscriptions] = input[:attached_subscriptions]
        end

        def humanized_name
          _("Auto-attach subscriptions")
        end

        def humanized_output
          humanized_lines = []
          humanized_lines << _("Auto-attaching subscriptions to '%{system}'") % {:system => input[:system][:name]}
          if output[:attached_subscriptions].nil?
            humanized_lines << _('In progress')
          elsif output[:attached_subscriptions].empty?
            humanized_lines << _('No subscriptions attached')
          else
            output[:attached_subscriptions].each do |subscription|
              humanized_lines << _("Attached subscription '%{name}'") % {:name => subscription[:pool][:productName]}
            end
          end
          humanized_lines.join("\n")
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
