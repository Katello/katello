module Actions
  module Katello
    module System
      class UnattachSubscriptions < Actions::EntryAction
        include Helpers::Presenter
        middleware.use Actions::Middleware::KeepCurrentUser
        middleware.use ::Actions::Middleware::RemoteAction

        input_format do
          param :id, Integer
          param :subscriptions, Hash
        end

        def plan(system, subscriptions)
          system.disable_auto_reindex!
          action_subject system
          sequence do
            unattach_plan = plan_action(::Actions::Candlepin::Consumer::UnattachSubscriptions, system, subscriptions) if ::Katello.config.use_cp
            plan_self(:results => unattach_plan.output[:results])
            plan_action(ElasticSearch::Reindex, system) if ::Katello.config.use_elasticsearch
          end
        end

        def run
          output[:results] = input[:results]
        end

        def humanized_name
          _("Unattach subscriptions")
        end

        def humanized_output
          humanized_lines = []
          humanized_lines << _("Unattaching subscriptions from '%{system}'") % { :system => input[:system][:name] }
          if output[:results].nil?
            humanized_lines << _('In progress')
          elsif output[:results].empty?
            humanized_lines << _('No subscriptions unattached')
          else
            humanized_lines << _("Unattached subscriptions")
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
