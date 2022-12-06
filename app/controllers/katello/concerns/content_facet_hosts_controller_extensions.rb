module Katello
  module Concerns
    module ContentFacetHostsControllerExtensions
      extend ActiveSupport::Concern
      included do
        before_action :set_up_content_view_environment, only: [:update]

        def set_up_content_view_environment
          return unless params[:host] && params[:host][:content_facet_attributes]
          cv_id = params[:host][:content_facet_attributes].delete(:content_view_id)
          env_id = params[:host][:content_facet_attributes].delete(:lifecycle_environment_id)
          Rails.logger.info "set_up_content_view_environment: cv_id=#{cv_id}, env_id=#{env_id}"
          if (cv_id.present? && env_id.present?)
            @host.content_facet.assign_single_environment(
              lifecycle_environment_id: env_id,
              content_view_id: cv_id
            )
            Rails.logger.info "set_up_content_view_environment: done"
          end
        end
      end
    end
  end
end
