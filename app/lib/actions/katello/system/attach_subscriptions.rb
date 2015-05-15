module Actions
  module Katello
    module System
      class AttachSubscriptions < Actions::EntryAction
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
            attach_plan = plan_action(::Actions::Candlepin::Consumer::AttachSubscriptions, system, subscriptions) if ::Katello.config.use_cp
            plan_self(:results => attach_plan.output[:results])
            plan_action(ElasticSearch::Reindex, system) if ::Katello.config.use_elasticsearch
          end
        end

        def run
          output[:results] = input[:results]
        end

        def humanized_name
          _("Attach subscriptions")
        end

        def humanized_output
          humanized_lines = []
          humanized_lines << _("Attaching subscriptions '%{subscriptions}' to '%{system}'") % {:subscriptions => input[:subscriptions],
                                                                                               :system => input[:system][:name]}
          if output[:results].nil?
            humanized_lines << _('In progress')
          elsif output[:results].empty?
            humanized_lines << _('No subscriptions attached')
          else
            output[:results].each do |result|
              result.each do |subscription|
                humanized_lines << _("Attached subscription '%{name}'") % {:name => subscription[:pool][:productName]}
              end
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
