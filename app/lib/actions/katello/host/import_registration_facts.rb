module Actions
  module Katello
    module Host
      # Imports RHSM facts for a newly registered host asynchronously, freeing
      # the Puma thread from the fact import work (up to 193 facts + fact name
      # creation) during the critical POST /rhsm/consumers registration path.
      #
      # Silently skips if the host no longer exists or has re-registered with a
      # different consumer UUID before the task ran — both are normal scenarios.
      #
      # After importing facts, refresh_statuses is called so that
      # RhelLifecycleStatus (which depends on distribution facts) is correctly
      # calculated. ErrataStatus remains UNKNOWN regardless — package data is
      # not available until the host uploads its package profile separately.
      class ImportRegistrationFacts < Actions::EntryAction
        def plan(host, facts)
          raise ArgumentError, _("host must be persisted") unless host&.persisted?
          raise ArgumentError, _("facts must be present") if facts.blank?
          raise ArgumentError, _("host must have a subscription facet") unless host.subscription_facet&.uuid
          plan_self(
            host_id: host.id,
            facts: facts,
            expected_uuid: host.subscription_facet.uuid
          )
        end

        def queue
          ::Katello::HOST_TASKS_QUEUE
        end

        def run
          host = ::Host.joins(:subscription_facet)
                       .find_by(id: input[:host_id], subscription_facet: { uuid: input[:expected_uuid] })
          return unless host

          User.as_anonymous_admin do
            ::Katello::Host::SubscriptionFacet.update_facts(host, input[:facts])
            host.refresh_statuses([::Katello::ErrataStatus, ::Katello::RhelLifecycleStatus])
          end
        end

        def humanized_name
          _('Import registration facts')
        end
      end
    end
  end
end
