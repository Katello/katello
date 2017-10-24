module Katello
  module Concerns
    module Containers
      module StepsControllerExtensions
        extend ActiveSupport::Concern

        module Overrides
          def set_form
            if step == :image && @state.image.nil?
              @docker_container_wizard_states_image = @state.build_image(:katello => true)
            else
              super
            end
          end

          def build_state
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
              super
            end
          end
        end

        included do
          prepend Overrides
        end
      end
    end
  end
end
