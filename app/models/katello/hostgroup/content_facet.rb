module Katello
  module Hostgroup
    class ContentFacet < Katello::Model
      audited :associated_with => :content_view_environment
      self.table_name = 'katello_hostgroup_content_facets'
      include Facets::HostgroupFacet

      belongs_to :kickstart_repository, :class_name => "::Katello::Repository", :inverse_of => :kickstart_hostgroup_content_facets
      belongs_to :content_view_environment, :class_name => "Katello::ContentViewEnvironment", :inverse_of => :hostgroup_content_facets
      belongs_to :content_source, :class_name => "::SmartProxy", :inverse_of => :hostgroup_content_facets

      validates_with Katello::Validators::HostgroupKickstartRepositoryValidator
      validates_with Katello::Validators::ContentViewEnvironmentValidator
      validates_with ::AssociationExistsValidator, attributes: [:content_source]

      validate :validate_content_view_and_environment_together

      # Virtual attributes for API compatibility
      # These provide backward compatibility for the deprecated content_view_id and lifecycle_environment_id
      # attributes. Since we now use a single content_view_environment_id relationship, we need to ensure
      # both values are provided together before we can look up the corresponding ContentViewEnvironment.
      #
      # The pending variables (@pending_content_view_id, @pending_lifecycle_environment_id) serve as a
      # temporary holding place when the API sends these values separately (e.g., in different order or
      # in a single hash). Once both values are set, assign_single_environment() attempts to find the
      # matching ContentViewEnvironment and assign it, then clears the pending variables.
      def content_view_id
        if instance_variable_defined?(:@pending_content_view_id)
          @pending_content_view_id
        else
          content_view_environment&.content_view_id
        end
      end

      def content_view_id=(value)
        # Store in pending variable and attempt to resolve to a ContentViewEnvironment
        @pending_content_view_id = value
        assign_cv_env_from_pending
      end

      def lifecycle_environment_id
        if instance_variable_defined?(:@pending_lifecycle_environment_id)
          @pending_lifecycle_environment_id
        else
          content_view_environment&.environment_id
        end
      end

      def lifecycle_environment_id=(value)
        # Store in pending variable and attempt to resolve to a ContentViewEnvironment
        @pending_lifecycle_environment_id = value
        assign_cv_env_from_pending
      end

      # Object getters for backward compatibility
      # These check for pending values first, then fall back to the CVEnv association
      def content_view
        cv_id = content_view_id
        return nil if cv_id.nil?
        return content_view_environment&.content_view if content_view_environment&.content_view_id == cv_id

        # If pending value differs from CVEnv, look it up
        ::Katello::ContentView.find_by(id: cv_id)
      end

      def lifecycle_environment
        lce_id = lifecycle_environment_id
        return nil if lce_id.nil?
        return content_view_environment&.lifecycle_environment if content_view_environment&.environment_id == lce_id

        # If pending value differs from CVEnv, look it up
        ::Katello::KTEnvironment.find_by(id: lce_id)
      end

      # Object setters for backward compatibility
      def content_view=(value)
        self.content_view_id = value&.id
      end

      def lifecycle_environment=(value)
        self.lifecycle_environment_id = value&.id
      end

      # Override the content_view_environment setter to always clear pending variables
      # when the association is assigned (either to a CVEnv or to nil)
      def content_view_environment=(cve)
        super(cve)
        clear_pending_variables
      end

      private

      def validate_content_view_and_environment_together
        # Get the effective CV and LCE IDs (including pending values)
        cv_id = content_view_id
        lce_id = lifecycle_environment_id

        # Both must be set together, or both must be nil
        if (cv_id.present? && lce_id.blank?) || (cv_id.blank? && lce_id.present?)
          errors.add(:base, _("Content view and lifecycle environment must both be set, or both be empty"))
        end
      end

      # Attempts to find and assign the ContentViewEnvironment when both content_view_id
      # and lifecycle_environment_id are explicitly set via the setters (API backwards compatibility).
      # This is called each time either setter is invoked, but only succeeds when BOTH
      # pending variables are set (not falling back to current values from the CVEnv).
      # Special case: If one is set to nil/blank (for inheritance), automatically clear both.
      def assign_cv_env_from_pending
        # Only proceed if at least one pending variable is set
        cv_id_set = instance_variable_defined?(:@pending_content_view_id)
        env_id_set = instance_variable_defined?(:@pending_lifecycle_environment_id)

        # Special case: If setting one to nil/blank (inherit parent), clear both for inheritance
        if inherit_parent_case?(cv_id_set, env_id_set)
          clear_content_view_environment
          return
        end

        # If both are explicitly set
        if cv_id_set && env_id_set
          cv_id = @pending_content_view_id
          env_id = @pending_lifecycle_environment_id

          if cv_id.nil? && env_id.nil?
            clear_content_view_environment
            return
          end

          # Both are set and at least one is non-nil, try to find the CVEnv
          if cv_id && env_id
            cve = find_content_view_environment(cv_id, env_id)
            self.content_view_environment = cve if cve
          end
        end
      end

      # Check if this is an "inherit parent" case: one field set to blank, the other not set at all
      # This happens when user selects "Inherit parent" for one field via API (sends nil/blank value)
      def inherit_parent_case?(cv_id_set, env_id_set)
        (cv_id_set && !env_id_set && @pending_content_view_id.blank?) ||
          (env_id_set && !cv_id_set && @pending_lifecycle_environment_id.blank?)
      end

      def clear_content_view_environment
        self.content_view_environment = nil
        # clear_pending_variables is called automatically by the content_view_environment= setter
      end

      def clear_pending_variables
        remove_instance_variable(:@pending_content_view_id) if instance_variable_defined?(:@pending_content_view_id)
        remove_instance_variable(:@pending_lifecycle_environment_id) if instance_variable_defined?(:@pending_lifecycle_environment_id)
      end

      def find_content_view_environment(cv_id, env_id)
        ::Katello::ContentViewEnvironment.where(
          content_view_id: cv_id,
          environment_id: env_id
        ).first
      end
    end
  end
end
