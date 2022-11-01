module Actions
  module Katello
    module Repository
      class ErrataMail < Actions::EntryAction
        def plan(repo)
          plan_self(:repo => repo.id, :associated_errata_before_syncing => repo.repository_errata.pluck(:erratum_id).uniq.sort.reverse, :new_associated_errata => [])
        end

        def run
          ::User.current = ::User.anonymous_admin
          repo = ::Katello::Repository.find(input[:repo])
          input[:new_associated_errata] = repo.repository_errata.pluck(:erratum_id).uniq.sort.reverse - input[:associated_errata_before_syncing]

          users = ::User.select { |user| user.receives?(:sync_errata) && user.organization_ids.include?(repo.organization.id) && user.can?(:view_products, repo.product) }.compact
          errata = ::Katello::Erratum.where(:id => input[:new_associated_errata])

          [:associated_errata_before_syncing, :new_associated_errata].each do |key|
            input[key] = "Trimmed list... (#{input[key].length} #{key.to_s.gsub('_', ' ')})" if input[key].length > 3
          end

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
