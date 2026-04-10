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

      validate :content_view_and_lifecycle_environment_together
      validate :content_view_environment_must_exist

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
      # These check for pending values first, then fall back to the CVE association
      def content_view
        cv_id = content_view_id
        return nil if cv_id.nil?
        return content_view_environment&.content_view if content_view_environment&.content_view_id == cv_id

        # If pending value differs from CVE, look it up
        ::Katello::ContentView.find_by(id: cv_id)
      end

      def lifecycle_environment
        lce_id = lifecycle_environment_id
        return nil if lce_id.nil?
        return content_view_environment&.lifecycle_environment if content_view_environment&.environment_id == lce_id

        # If pending value differs from CVE, look it up
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
      # when the association is assigned (either to a CVE or to nil)
      def content_view_environment=(cve)
        super(cve)
        clear_pending_variables
      end

      private

      def content_view_and_lifecycle_environment_together
        # Get the current or pending values
        cv_id = pending_or_current_cv_id
        env_id = pending_or_current_env_id

        # Both must be set together, or both must be nil
        if (cv_id.present? && env_id.blank?) || (env_id.present? && cv_id.blank?)
          errors.add(:base, _("Content view and lifecycle environment must be set together"))
        end
      end

      def content_view_environment_must_exist
        # Only validate if we're trying to assign new values
        return unless pending_values_set?

        cv_id = pending_or_current_cv_id
        env_id = pending_or_current_env_id

        # Skip if both are nil (clearing the association)
        return if cv_id.nil? && env_id.nil?

        # Skip if one is missing (handled by content_view_and_lifecycle_environment_together)
        return unless cv_id.present? && env_id.present?

        # Verify that a ContentViewEnvironment record exists for this pair
        cve = ::Katello::ContentViewEnvironment.find_by(
          content_view_id: cv_id,
          environment_id: env_id
        )

        unless cve
          cv = ::Katello::ContentView.find_by(id: cv_id)
          env = ::Katello::KTEnvironment.find_by(id: env_id)
          errors.add(:base, _("No content view environment found for content view '%{cv}' in lifecycle environment '%{env}'") %
            { cv: cv&.name || cv_id, env: env&.name || env_id })
        end
      end

      # Attempts to find and assign the ContentViewEnvironment when both content_view_id
      # and lifecycle_environment_id are available (either from pending variables or current values).
      # This is called each time either setter is invoked, but only succeeds when both values are present.
      def assign_cv_env_from_pending
        cv_id = pending_or_current_cv_id
        env_id = pending_or_current_env_id

        # If both are explicitly set to nil, clear the CVE
        if cv_id.nil? && env_id.nil? && pending_values_set?
          clear_content_view_environment
          return
        end

        # Wait until both values are available before attempting lookup
        return unless cv_id && env_id

        cve = find_content_view_environment(cv_id, env_id)
        self.content_view_environment = cve if cve
      end

      def pending_or_current_cv_id
        instance_variable_defined?(:@pending_content_view_id) ? @pending_content_view_id : content_view_environment&.content_view_id
      end

      def pending_or_current_env_id
        instance_variable_defined?(:@pending_lifecycle_environment_id) ? @pending_lifecycle_environment_id : content_view_environment&.environment_id
      end

      def pending_values_set?
        instance_variable_defined?(:@pending_content_view_id) || instance_variable_defined?(:@pending_lifecycle_environment_id)
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
