module Actions
  module Katello
    module ContentView
      class ErrataMail < Actions::EntryAction
        def plan(content_view, environment)
          plan_self(:content_view => content_view.id, :environment => environment.id)
        end

        def run
          ::User.current = ::User.anonymous_admin

          content_view = ::Katello::ContentView.find(input[:content_view])
          environment = ::Katello::KTEnvironment.find(input[:environment])
          users = ::User.select { |user| user.receives?(:katello_promote_errata) && user.can?(:view_content_views, content_view) }

          begin
            MailNotification[:katello_promote_errata].deliver_now(:users => users, :content_view => content_view, :environment  => environment) unless users.blank?
          rescue => e
            message = _('Unable to send errata e-mail notification: %{error}' % {:error => e})
            Rails.logger.error(message)
            output[:result] = message
          end
        end

        def finalize
          ::User.current = nil
        end

        def rescue_strategy_for_self
          # If sending mail fails do not cause any calling tasks to fail
          # but mark the task in a WARNING state with the error message.
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
