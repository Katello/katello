module Katello
  module Concerns
    module OrganizationsControllerExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Triggers

      included do
        alias_method_chain :destroy, :dynflow
        alias_method_chain :create, :dynflow
      end

      def destroy_with_dynflow
        if @taxonomy.is_a?(Organization)
          begin
            async_task(::Actions::Katello::Organization::Destroy, @taxonomy,
                       ::Organization.current)
            process_success :success_msg => _("Organization %s is being deleted.") % @taxonomy.name
          rescue ::Katello::Errors::OrganizationDestroyException => ex
            process_error(:error_msg => ex.message)
          end
        else
          destroy_without_dynflow
        end
      end

      def create_with_dynflow
        if taxonomy_class == Organization
          begin
            @taxonomy = Organization.new(params[:organization])
            sync_task(::Actions::Katello::Organization::Create, @taxonomy)
            @taxonomy.reload
            if @count_nil_hosts > 0
              redirect_to send("step2_#{taxonomy_single}_path", @taxonomy)
            else
              process_success(:object => @taxonomy, :success_redirect => send("edit_#{taxonomy_single}_path", @taxonomy))
            end
          rescue ActiveRecord::RecordInvalid
            process_error(:render => "taxonomies/new", :object => @taxonomy)
          rescue StandardError => ex
            process_error(:render => "taxonomies/new", :object => @taxonomy, :error_msg => ex.message)
          end
        else
          create_without_dynflow
        end
      end
    end
  end
end
