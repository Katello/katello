module Katello
  module Concerns
    module Api::V2::HostsControllerExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Triggers

      included do
        before_filter :check_env_and_cv, :only => [:update]

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

        def action_permission
          case params[:action]
          when 'host_collections'
            'edit'
          else
            super
          end
        end

        def check_env_and_cv
          if !@host.content_facet.nil? && (params[:lifecycle_environment_id] || params[:content_view_id])
            raise ::Foreman::Exception.new(N_("Can't update content view and lifecycle environment for existing content host."))
          end
        end
      end
    end
  end
end
