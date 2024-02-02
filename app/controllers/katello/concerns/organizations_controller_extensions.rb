module Katello
  module Concerns
    module OrganizationsControllerExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Triggers
      include Foreman::Controller::Flash

      module Overrides
        def destroy
          if @taxonomy.is_a?(Organization)
            begin
              async_task(::Actions::Katello::Organization::Destroy, @taxonomy,
                         ::Organization.current)
              process_success :success_msg => _("Organization %s is being deleted.") % @taxonomy.name
            rescue ::Katello::Errors::OrganizationDestroyException => ex
              process_error(:error_msg => ex.message)
            end
          else
            super
          end
        end

        def create
          if taxonomy_class == Organization
            begin
              @taxonomy = Organization.new(resource_params)
              ::Katello::OrganizationCreator.new(@taxonomy).create!
              @taxonomy.reload
              switch_taxonomy
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
