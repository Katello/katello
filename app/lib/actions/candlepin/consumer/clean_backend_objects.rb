module Actions
  module Candlepin
    module Consumer
      class CleanBackendObjects < Actions::EntryAction
        include Actions::RecurringAction
        def plan
          plan_self
        end

        def run
          output[:results] = {
            hosts_with_nil_facets: [],
            hosts_with_no_subscriptions: [],
            orphaned_consumers: [],
            errors: [],
          }

          User.as_anonymous_admin do
            # Set bulk load size for Candlepin operations
            original_candlepin_page_size = SETTINGS[:katello][:candlepin][:bulk_load_size]
            SETTINGS[:katello][:candlepin][:bulk_load_size] = 125

            # Gather data from Candlepin and Katello
            candlepin_uuids = fetch_candlepin_uuids
            katello_candlepin_uuids = fetch_katello_candlepin_uuids

            # Find hosts with issues
            cleanup_hosts_with_nil_facets
            cleanup_hosts_with_no_subscriptions(candlepin_uuids)

            # Clean up orphaned Candlepin consumers
            cleanup_candlepin_orphans(candlepin_uuids, katello_candlepin_uuids)
            SETTINGS[:katello][:candlepin][:bulk_load_size] = original_candlepin_page_size
          end
        end

        def humanized_name
          _('Clean Backend Objects')
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        private

        def fetch_candlepin_uuids
          ::Katello::Resources::Candlepin::Consumer.all_uuids
        end

        def fetch_katello_candlepin_uuids
          ::Katello::Host::SubscriptionFacet.pluck(:uuid).compact
        end

        def cleanup_hosts_with_nil_facets
          nil_sub = ::Katello::Host::SubscriptionFacet.where(uuid: nil).select(:host_id)
          hosts = ::Host.where(id: nil_sub)

          hosts.each do |host|
            begin
              output[:results][:hosts_with_nil_facets] << {
                id: host.id,
                name: host.name,
                uuid: nil,
              }

              unregister_options = host_unregister_options(host)
              ::Katello::RegistrationManager.unregister_host(host, unregister_options)
            rescue RestClient::ResourceNotFound
              # Ignore if already gone
            rescue => e
              output[:results][:errors] << {
                type: 'unregister_host',
                host_id: host&.id,
                host_name: host&.name,
                message: e.message,
              }
            end
          end
        end

        def cleanup_hosts_with_no_subscriptions(candlepin_uuids)
          hosts = ::Host.includes(:subscription_facet)
                        .where.not(katello_subscription_facets: { uuid: candlepin_uuids })
                        .where.not(katello_subscription_facets: { uuid: nil })

          hosts.each do |host|
            begin
              output[:results][:hosts_with_no_subscriptions] << {
                id: host.id,
                name: host.name,
                uuid: host.subscription_facet&.uuid,
              }

              unregister_options = host_unregister_options(host)
              ::Katello::RegistrationManager.unregister_host(host, unregister_options)
            rescue RestClient::ResourceNotFound
              # Ignore if already gone
            rescue => e
              output[:results][:errors] << {
                type: 'unregister_host',
                host_id: host&.id,
                host_name: host&.name,
                message: e.message,
              }
            end
          end
        end

        def cleanup_candlepin_orphans(candlepin_uuids, katello_candlepin_uuids)
          orphaned_uuids = candlepin_uuids - katello_candlepin_uuids

          orphaned_uuids.each do |consumer_uuid|
            begin
              output[:results][:orphaned_consumers] << {
                uuid: consumer_uuid,
              }

              ::Katello::Resources::Candlepin::Consumer.destroy(consumer_uuid)
            rescue RestClient::ResourceNotFound
              # Ignore if already gone
            rescue => e
              output[:results][:errors] << {
                type: 'destroy_consumer',
                consumer_uuid: consumer_uuid,
                message: e.message,
              }
            end
          end
        end

        def host_unregister_options(host)
          if host.managed? || host.compute_resource
            { unregistering: true }
          else
            {}
          end
        end
      end
    end
  end
end
