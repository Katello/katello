module Actions
  module Katello
    module Repository
      class ErrataMail < Actions::EntryAction
        middleware.use Actions::Middleware::ExecuteIfContentsChanged

        def plan(repo, last_updated = nil, contents_changed = nil)
          last_updated ||= repo.repository_errata.order('updated_at ASC').last.try(:updated_at) || Time.now
          plan_self(:repo => repo.id, :last_updated => last_updated.to_s, :contents_changed => contents_changed)
        end

        def run
          ::User.current = ::User.anonymous_admin

          repo = ::Katello::Repository.find(input[:repo])
          users = ::User.select { |user| user.receives?(:sync_errata) && user.organization_ids.include?(repo.organization.id) && user.can?(:view_products, repo.product) }.compact
          errata = ::Katello::Erratum.where(:id => repo.repository_errata.where('katello_repository_errata.updated_at > ?', input[:last_updated].to_datetime).pluck(:erratum_id))

          begin
            MailNotification[:sync_errata].deliver(:users => users, :repo => repo, :errata => errata) unless (users.blank? || errata.blank?)
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
