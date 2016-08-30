module Actions
  module Katello
    module Host
      class HypervisorsUpdate < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(hypervisor_results)
          plan_self(:hypervisor_results => hypervisor_results)
        end

        def run
          output[:results] = input[:results]
        end

        def finalize
          hypervisor_results = input[:hypervisor_results]

          %w(created updated unchanged).each do |group|
            if hypervisor_results[group]
              hypervisor_results[group].each do |hypervisor|
                update_or_create_hypervisor(hypervisor)
              end
            end
          end
        end

        # rubocop:disable MethodLength
        def update_or_create_hypervisor(hypervisor_json)
          organization = ::Organization.find_by(:label => hypervisor_json[:owner][:key])

          # Since host names must be unique yet hypervisors may have unique subscription
          # facets in different orgs
          duplicate_name = "virt-who-#{hypervisor_json[:name]}-#{organization.id}"
          host = ::Katello::Host::SubscriptionFacet.find_by(:uuid => hypervisor_json[:uuid]).try(:host)
          host ||= ::Host.find_by(:name => duplicate_name)
          if host && host.organization.try(:id) != organization.id
            fail _("Host '%{name}' does not belong to an organization") % {:name => host.name} unless host.organization
            host = nil
          end

          host ||= create_host_for_hypervisor(duplicate_name, organization)
          host.subscription_facet ||= ::Katello::Host::SubscriptionFacet.new
          host.subscription_facet.host_id = host.id
          host.subscription_facet.update_from_consumer_attributes(hypervisor_json)
          host.subscription_facet.uuid = hypervisor_json[:uuid]
          host.subscription_facet.save!

          # TODO: Remove this legacy http://projects.theforeman.org/issues/12556
          unless host.content_host
            if host.content_facet
              content_view = host.content_facet.content_view
              environment = host.content_facet.lifecycle_environment
            else
              content_view = host.organization.default_content_view
              environment = host.organization.library
            end

            hypervisor = ::Katello::Hypervisor.new(:environment_id => environment.id,
                                        :content_view_id => content_view.id)
            hypervisor.name = host.name
            hypervisor.cp_type = 'hypervisor'
            hypervisor.orchestration_for = :hypervisor
            hypervisor.load_from_cp(hypervisor_json)
            hypervisor.save!
            host.content_host = hypervisor
          end

          host.save!
        end

        def create_host_for_hypervisor(name, organization, location = nil)
          location ||= Location.default_location
          host = ::Host::Managed.new(:name => name, :organization => organization,
                                     :location => location, :managed => false)
          host.save!
          host
        end
      end
    end
  end
end
