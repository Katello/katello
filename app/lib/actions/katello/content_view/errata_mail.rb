module Actions
  module Katello
    module ContentView
      class ErrataMail < Actions::EntryAction
        def plan(content_view, environment)
          plan_self(:content_view => content_view.id, :environment => environment.id)
        end

        def run
          MailNotification[:katello_promote_errata].deliver(:content_view => input[:content_view],
                                                            :environment => input[:environment])
        end
      end
    end
  end
end
