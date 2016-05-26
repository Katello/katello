module Actions
  module Katello
    module Host
      class HypervisorsUpdate < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(environment, content_view, hypervisor_results)
          plan_self(:environment_id => environment.id, :content_view_id => content_view.id,
                    :hypervisor_results => hypervisor_results)
        end

        def run
          output[:results] = input[:results]
        end

        def finalize
          environment = ::Katello::KTEnvironment.find(input[:environment_id])
          content_view = ::Katello::ContentView.find(input[:content_view_id])
          hypervisor_results = input[:hypervisor_results]

          %w(created updated unchanged).each do |group|
            if hypervisor_results[group]
              hypervisor_results[group].each do |hypervisor|
                update_or_create_hypervisor(environment, content_view, hypervisor)
              end
            end
          end
        end

        def update_or_create_hypervisor(environment, content_view, hypervisor_json)
          name = hypervisor_json[:name]

          # Since host names must be unique yet hypervisors may have unique subscription
          # facets in different orgs
          duplicate_name = "virt-who-#{name}-#{content_view.organization.id}"
          host = find_host_by_uuid_or_name(hypervisor_json)
          if host
            fail _("Host '%{name}' does not belong to an organization") % {:name => name} unless host.organization
            if host.organization.id != content_view.organization.id
              name = duplicate_name
              host = nil
            end
          else
            name = duplicate_name
          end

          host ||= create_host_for_hypervisor(name, content_view.organization)
          host.subscription_facet ||= ::Katello::Host::SubscriptionFacet.new
          host.subscription_facet.host_id = host.id
          host.subscription_facet.update_from_consumer_attributes(hypervisor_json)
          host.subscription_facet.uuid = hypervisor_json[:uuid]
          host.subscription_facet.save!

          # TODO: Remove this legacy
          # http://projects.theforeman.org/issues/12556
          unless ::Katello::Hypervisor.find_by(:name => name)
            hypervisor = ::Katello::Hypervisor.new(:environment_id => environment.id,
                                        :content_view_id => content_view.id)
            hypervisor.name = name
            hypervisor.cp_type = 'hypervisor'
            hypervisor.orchestration_for = :hypervisor
            hypervisor.load_from_cp(hypervisor_json)
            hypervisor.save!
            host.content_host = hypervisor
          end

          host.save!
        end

        def find_host_by_uuid_or_name(hypervisor_json)
          facet = ::Katello::Host::SubscriptionFacet.find_by(:uuid => hypervisor_json[:uuid])
          facet.nil? ? ::Host.find_by(:name => hypervisor_json[:name]) : facet.host
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
