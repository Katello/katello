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

          MailNotification[:katello_promote_errata].deliver(:users => users, :content_view => content_view, :environment  => environment) unless users.blank?
        end

        def finalize
          ::User.current = nil
        end
      end
    end
  end
end
