module Katello
  module Concerns
    module Api::V2::HostsControllerExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Triggers

      included do
        alias_method_chain :action_permission, :katello

        def destroy
          sync_task(::Actions::Katello::Host::Destroy, @host)
          process_response(:object => @host)
        end

        api :PUT, "/hosts/:host_id/host_collections", N_("Alter a hosts host collections")
        param :host_id, :identifier, :required => true, :desc => N_("The id of the host to alter")
        param :host_collection_ids, Array, :required => true, :desc => N_("List of host collection ids to update")
        def host_collections
          @host.host_collection_ids = params[:host_collection_ids]
          @host.save!
          render(:locals => { :resource => @host }, :template => 'katello/api/v2/hosts/show', :status => 200)
        end
      end

      private

      def action_permission_with_katello
        case params[:action]
        when 'host_collections'
          'edit'
        else
          action_permission_without_katello
        end
      end
    end
  end
end
