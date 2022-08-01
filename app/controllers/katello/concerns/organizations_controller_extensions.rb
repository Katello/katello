module Katello
  module Concerns
    module OrganizationsControllerExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Triggers
      include Foreman::Controller::Flash

      module Overrides
        def edit
          @can_toggle_sca = Katello::UpstreamConnectionChecker.new(@taxonomy).can_connect? &&
            (@taxonomy.upstream_consumer.simple_content_access_eligible? || @taxonomy.simple_content_access?)
          super
        end

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
              sca = ::Foreman::Cast.to_bool(params[:simple_content_access])
              ::Katello::OrganizationCreator.new(@taxonomy, sca: sca).create!
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

      def update
        super # we run super first here so that flash messages won't be in a confusing order
        return if params[:simple_content_access].nil?
        sca_param = ::Foreman::Cast.to_bool(params[:simple_content_access])
        if sca_param && !@taxonomy.simple_content_access?
          # user has requested SCA enable
          task = async_task(::Actions::Katello::Organization::SimpleContentAccess::Enable, params[:id])
          info "Enabling Simple Content Access for organization #{@taxonomy.name}.",
            link: { text: "View progress on the Tasks page", href: "/foreman_tasks/tasks/#{task&.id}" }
        elsif !sca_param && @taxonomy.simple_content_access?
          # user has requested SCA disable
          task = async_task(::Actions::Katello::Organization::SimpleContentAccess::Disable, params[:id])
          info "Disabling Simple Content Access for organization #{@taxonomy.name}.",
            link: { text: "View progress on the Tasks page", href: "/foreman_tasks/tasks/#{task&.id}" }
        end
      end

      included do
        prepend Overrides
      end
    end
  end
end
