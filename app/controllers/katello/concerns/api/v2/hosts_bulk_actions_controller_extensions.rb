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
      end

      included do
        prepend Overrides
      end
    end
  end
end
