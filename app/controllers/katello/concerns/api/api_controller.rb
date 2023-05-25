module Katello
  module Concerns
    module Api::ApiController
      extend ActiveSupport::Concern
      include Katello::Concerns::FilterSensitiveData

      included do
        include ForemanTasks::Triggers

        respond_to :json
        before_action :set_gettext_locale
      end

      # override warden current_user (returns nil because there is no user in that scope)
      def current_user
        # get the logged user from the correct scope
        User.current
      end

      class_methods do
        def katello_agent_deprecation_text
          N_("WARNING: Katello-agent is deprecated and will be removed in %s. Migrate to remote execution now.") % katello_agent_removal_release
        end

        def katello_agent_removal_release
          N_("Katello 4.10")
        end
      end

      protected

      def request_from_katello_cli?
        request.user_agent.to_s =~ /^katello-cli/
      end

      # For situations where rhsm/subscirption-manager expect a bit
      # different behaviour.
      def request_from_rhsm?
        # We should rather use "x-python-rhsm-version" that are sent in
        # headers from subcription-manager, but this was added quite
        # recently: https://bugzilla.redhat.com/show_bug.cgi?id=790481.
        # For compatibility reasons we use the checking for katello_cli
        # instead for now. Therefore this method should be used only
        # rarely in cases where the expected behaviour differs between
        # this two agents, without large impact on other possible clients.
        !request_from_katello_cli?
      end

      def process_action(method_name, *args)
        super(method_name, *args)
        Rails.logger.debug "With body: #{filter_sensitive_data(response.body)}\n"
      end

      def split_order(order)
        if order
          order.split("|")
        else
          [:name_sort, "ASC"]
        end
      end

      def resource
        resource = instance_variable_get(:"@#{resource_name}")
        fail 'no resource loaded' if resource.nil?
        resource
      end

      def resource_collection
        resource = instance_variable_get(:"@#{resource_collection_name}")
        fail 'no resource collection loaded' if resource.nil?
        resource
      end

      def resource_collection_name
        controller_name
      end

      def resource_name
        controller_name.singularize
      end

      def respond(options = {})
        method_name = 'respond_for_' + params[:action].to_s
        fail "automatic response method '%s' not defined" % method_name unless respond_to?(method_name, true)
        return send(method_name.to_sym, options)
      end

      def format_bulk_action_messages(args = {})
        models     = args.fetch(:models)
        authorized = args.fetch(:authorized)
        messages   = {:success => [], :error => []}

        unauthorized = models - authorized

        messages[:success] << args.fetch(:success) % authorized.length if authorized.present?
        unauthorized.each { |item| messages[:error] << args.fetch(:error) % item }

        messages
      end
    end
  end
end
