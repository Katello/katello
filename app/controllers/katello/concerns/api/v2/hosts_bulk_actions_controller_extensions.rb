module Katello
  module Concerns
    # overrides Foreman Api::V2::HostsBulkActionsController
    module Api::V2::HostsBulkActionsControllerExtensions
      extend ActiveSupport::Concern
      require 'active_support/core_ext/string/inflections'

      module Overrides
        def bulk_destroy
          destroyed_count = @hosts.count
          @hosts.in_batches.each_record do |host|
            Katello::RegistrationManager.unregister_host(host, :unregistering => false)
          end
          process_response(true, { :message => _("Deleted %{host_count} %{hosts}") % { :host_count => destroyed_count, :hosts => 'host'.pluralize(destroyed_count) }})
        end

        def assign_organization
          registered_host = find_editable_hosts.where.not(organization_id: params[:id]).joins(:subscription_facet).first
          if registered_host
            render_error :custom_error, :status => :bad_request, :locals => { :message => _("Unregister host %s before assigning an organization.") % registered_host.name }
            return
          end

          super
        end
      end

      included do
        prepend Overrides
      end
    end
  end
end
