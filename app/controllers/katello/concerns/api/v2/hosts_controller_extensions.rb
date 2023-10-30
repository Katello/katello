module Katello
  module Concerns
    module Api::V2::HostsControllerExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Triggers
      require 'active_support/core_ext/string/inflections'

      module Overrides
        def action_permission
          case params[:action]
          when 'host_collections'
            'edit'
          else
            super
          end
        end
      end

      included do
        prepend Overrides
        before_action :purpose_addon_params, only: [:create, :update]

        def destroy
          Katello::RegistrationManager.unregister_host(@host, :unregistering => false)
          process_response(:object => @host)
        end

        def bulk_destroy
          destroyed_count = @hosts.count
          @hosts.in_batches.each_record do |host|
            Katello::RegistrationManager.unregister_host(host, :unregistering => false)
          end
          process_response(true, { :message => _("Deleted %{host_count} %{hosts}") % { :host_count => destroyed_count, :hosts => 'host'.pluralize(destroyed_count) }})
        end

        api :PUT, "/hosts/:host_id/host_collections", N_("Alter a host's host collections")
        param :host_id, :number, :required => true, :desc => N_("The id of the host to alter")
        param :host_collection_ids, Array, :required => true, :desc => N_("List of host collection ids to update")
        def host_collections
          @host.host_collection_ids = params[:host_collection_ids]
          @host.save!
          render(:locals => { :resource => @host }, :template => 'katello/api/v2/hosts/show', :status => :ok)
        end

        def purpose_addon_params
          addons = params.dig(:host, :subscription_facet_attributes, :purpose_addons)
          return if addons.nil?
          params[:host][:subscription_facet_attributes][:purpose_addon_ids] = addons.map { |addon_name| ::Katello::PurposeAddon.find_or_create_by(name: addon_name).id }
          params[:host][:subscription_facet_attributes].delete(:purpose_addons)
        end
      end
    end
  end
end
