module Katello
  module Concerns
    module Containers
      module StepsControllerExtensions
        extend ActiveSupport::Concern
        included do
          alias_method_chain :set_form, :katello
          alias_method_chain :build_state, :katello
        end

        def set_form_with_katello
          if step == :image && @state.image.nil?
            @docker_container_wizard_states_image = @state.build_image(:katello => true)
          else
            set_form_without_katello
          end
        end

        def build_state_with_katello
          if step == :image && params.key?(:katello)
            repo = nil
            tag = nil
            capsule_id = nil
            if params[:repository] && params[:repository][:id]
              repo = Repository.where(:id => params[:repository][:id]).first
            end

            if params[:tag] && params[:tag][:id]
              tag = DockerMetaTag.where(:id => params[:tag][:id]).first
            end
            if params[:capsule] && params[:capsule][:id]
              capsule_id = params[:capsule][:id]
            end

            katello_content = {
              organization_id: params[:organization_id],
              environment_id: params.fetch(:kt_environment, {})[:id],
              content_view_id: params.fetch(:content_view, {})[:id],
              repository_id: repo.try(:id),
              tag_id: tag.try(:id)
            }
            @docker_container_wizard_states_image = @state.build_image(:repository_name => repo.try(:container_repository_name),
                                :tag => tag.try(:name),
                                :capsule_id => capsule_id,
                                :katello => true, :katello_content => katello_content)
          else
            build_state_without_katello
          end
        end
      end
    end
  end
end
