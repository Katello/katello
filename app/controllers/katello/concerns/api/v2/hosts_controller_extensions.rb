module Katello
  module Concerns
    module Api::V2::HostsControllerExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Triggers
      include Katello::Concerns::Api::V2::MultiCVParamsHandling

      module Overrides
        def action_permission
          case params[:action]
          when 'host_collections'
            'edit'
          else
            super
          end
        end

        def resource_scope(options = {})
          scope = super(options)
          # Eager load host_collections for index action to avoid N+1 queries
          # Using preload to force loading even if not accessed
          if params[:action] == 'index'
            scope = scope.preload(:host_collections) if scope.respond_to?(:preload)
          end
          scope
        end
      end

      included do
        prepend Overrides
        around_action :handle_content_view_environments_for_create, only: [:create]
        before_action :handle_content_view_environments_for_update, only: [:update]

        def destroy
          Katello::RegistrationManager.unregister_host(@host, :unregistering => false)
          process_response(:object => @host)
        end

        api :PUT, "/hosts/:host_id/host_collections", N_("Alter a host's host collections")
        param :host_id, :number, :required => true, :desc => N_("The id of the host to alter")
        param :host_collection_ids, Array, :required => true, :desc => N_("List of host collection ids to update")
        def host_collections
          @host.host_collection_ids = params[:host_collection_ids]
          @host.save!
          render(:locals => { :resource => @host }, :template => 'katello/api/v2/hosts/show', :status => :ok)
        end

        def handle_content_view_environments_for_create
          # validations should occur before the action so that the request can fail and not render multiple responses
          cves = validate_content_view_environment_params
          yield
          # the actual assigning needs to wait until the host is created
          set_content_view_environments(cves)
        end

        def handle_content_view_environments_for_update
          cves = validate_content_view_environment_params
          set_content_view_environments(cves)
        end

        def validate_content_view_environment_params
          content_facet_attributes = params.dig(:host, :content_facet_attributes)
          return if content_facet_attributes.blank? ||
          (cve_params[:content_view_id].present? && cve_params[:lifecycle_environment_id].present?)

          cves = ::Katello::ContentViewEnvironment.fetch_content_view_environments(
            labels: cve_params[:content_view_environments],
            ids: cve_params[:content_view_environment_ids],
            organization: find_organization || @host&.organization)
          if cves.blank?
            handle_errors(labels: cve_params[:content_view_environments],
              ids: cve_params[:content_view_environment_ids])
          end
          cves
        end

        # rubocop:disable Naming/AccessorMethodName
        def set_content_view_environments(cves)
          return if cves.blank?
          if @host.blank?
            Rails.logger.debug "No host; not assigning content view environments"
            return
          elsif @host&.content_facet.blank?
            content_facet = Katello::Host::ContentFacet.new(host: @host)
            @host.content_facet = content_facet
          end
          @host.content_facet.content_view_environments = cves
        end
        # rubocop:enable Naming/AccessorMethodName

        def cve_params
          params.require(:host).require(:content_facet_attributes).permit(:content_view_id, :lifecycle_environment_id, content_view_environments: [], content_view_environment_ids: [])
        end
      end
    end
  end
end
