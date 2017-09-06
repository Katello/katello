module Katello
  module Concerns
    module Api::V2::HostgroupsControllerExtensions
      module ApiPieExtensions
        extend ::Apipie::DSL::Concern

        update_api(:create, :update) do
          param :hostgroup, Hash do
            param :content_source_id, :number, :desc => N_('Content source ID')
            param :content_view_id, :number, :desc => N_('Content view ID')
            param :lifecycle_environment_id, :number, :desc => N_('Lifecycle environment ID')
            param :kickstart_repository_id, :number, :desc => N_('Kickstart repository ID')
          end
        end
      end

      extend ActiveSupport::Concern

      included do
        include ApiPieExtensions

        def create
          @hostgroup = Hostgroup.new(hostgroup_params)
          process_response @hostgroup.save
        end

        def update
          process_response @hostgroup.update_attributes(hostgroup_params)
        end

        def show
          @render_template = 'katello/api/v2/hostgroups_extensions/show'
          render @render_template
        end
      end
    end
  end
end
