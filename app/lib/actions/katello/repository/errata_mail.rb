module Actions
  module Katello
    module Repository
      class ErrataMail < Actions::EntryAction
        def plan(repo)
          last_updated = repo.repository_errata.order('updated_at ASC').last.try(:updated_at) || Time.now
          plan_self(:repo => repo.id, :last_updated => last_updated.to_s)
        end

        def run
          ::User.current = ::User.anonymous_admin
          MailNotification[:katello_sync_errata].deliver(:repo => input[:repo], :last_updated => input[:last_updated])
        end

        def finalize
          ::User.current = nil
        end
      end
    end
  end
end
