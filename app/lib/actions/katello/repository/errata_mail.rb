module Actions
  module Katello
    module Repository
      class ErrataMail < Actions::EntryAction
        middleware.use Actions::Middleware::ExecuteIfContentsChanged

        def plan(repo, contents_changed = nil)
          associated_errata_ids = repo.repository_errata.pluck(:erratum_id).uniq.sort
          plan_self(:repo => repo.id, :contents_changed => contents_changed, :associated_errata_ids => associated_errata_ids)
        end

        def run
          ::User.current = ::User.anonymous_admin
          repo = ::Katello::Repository.find(input[:repo])
          old_associated_errata_ids = input[:associated_errata_ids]
          new_associated_errata_ids = repo.repository_errata.pluck(:erratum_id).uniq.sort
          new_errata_ids = new_associated_errata_ids - old_associated_errata_ids

          users = ::User.select { |user| user.receives?(:sync_errata) && user.organization_ids.include?(repo.organization.id) && user.can?(:view_products, repo.product) }.compact
          errata = ::Katello::Erratum.where(:id => new_errata_ids)
          input[:associated_errata_ids].clear
          input[:associated_errata_ids] = 'TRIMMED'

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
