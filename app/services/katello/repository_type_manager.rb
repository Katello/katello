module Katello
  class RepositoryTypeManager
    PULP3_FEATURE = "Pulpcore".freeze

    @defined_repository_types = {}
    @enabled_repository_types = {}
    begin
      @pulp_primary = ::SmartProxy.unscoped.detect { |proxy| !proxy.setting(PULP3_FEATURE, 'mirror') }
    rescue ActiveRecord::StatementInvalid
      @pulp_primary = nil
    end
    class << self
      private :new
      attr_reader :defined_repository_types

      # Plugin constructor
      def register(id, &block)
        if @pulp_primary&.has_feature?(PULP3_FEATURE) && @pulp_primary&.capabilities(PULP3_FEATURE)&.empty?
          fix_pulp3_capabilities
        end
        defined_repo_type = find_defined(id)
        if defined_repo_type.blank?
          defined_repo_type = ::Katello::RepositoryType.new(id)
          defined_repo_type.instance_eval(&block) if block_given?
          @defined_repository_types[id.to_s] = defined_repo_type
        end
        if find(id).blank? && defined_repo_type.present?
          enabled_repository_types[id.to_s] = defined_repo_type if pulp3_plugin_installed?(id)
        end
      end

      def fix_pulp3_capabilities
        save_pulp_primary if @pulp_primary.nil?
        @pulp_primary&.refresh
        if @pulp_primary&.capabilities(PULP3_FEATURE)&.empty?
          fail Katello::Errors::PulpcoreMissingCapabilities
        end
      end

      def enabled_repository_types(update = true)
        disabled_types = @defined_repository_types.keys - @enabled_repository_types.keys
        if update && disabled_types.present?
          disabled_types.each { |repo_type| update_enabled_repository_type(repo_type.to_s) }
        end
        @enabled_repository_types
      end

      def creatable_repository_types(enabled_only = true)
        repo_types = enabled_only ? enabled_repository_types : defined_repository_types
        repo_types.select do |repo_type, _|
          creatable_by_user?(repo_type, enabled_only)
        end
      end

      def generic_repository_types(enabled_only = true)
        repo_types = enabled_only ? enabled_repository_types : defined_repository_types
        repo_types.select do |_, values|
          values.pulp3_service_class == Katello::Pulp3::Repository::Generic
        end
      end

      def pulp3_plugin_installed?(repository_type)
        save_pulp_primary
        @pulp_primary&.capabilities(PULP3_FEATURE)&.include?(@defined_repository_types[repository_type].pulp3_plugin)
      end

      def enabled_content_types(enabled_only = true)
        repo_types = enabled_only ? enabled_repository_types : defined_repository_types
        list = repo_types.values.map do |type|
          type.content_types.map(&:model_class).flatten.map { |ct| ct::CONTENT_TYPE }
        end
        list.flatten
      end

      def indexable_content_types
        enabled_repository_types.
                  values.
                  map(&:content_types_to_index).
                  flatten
      end

      def creatable_by_user?(repository_type, enabled_only = true)
        type = enabled_only ? find(repository_type) : find_defined(repository_type)
        return false unless type
        type.allow_creation_by_user
      end

      def removable_content_types(enabled_only = true)
        repo_types = enabled_only ? enabled_repository_types : defined_repository_types
        list = repo_types.values.map do |type|
          type.content_types.select(&:removable)
        end
        list.flatten
      end

      def uploadable_content_types(enabled_only = true)
        repo_types = enabled_only ? enabled_repository_types : defined_repository_types
        list = repo_types.values.map do |type|
          type.content_types.select(&:uploadable)
        end
        list.flatten
      end

      def find_defined(repository_type)
        @defined_repository_types[repository_type.to_s]
      end

      def find(repository_type)
        # Skip updating disabled repo types because find() updates the input type if necessary
        found_repo_type = enabled_repository_types(false)[repository_type.to_s]
        if found_repo_type.blank?
          found_repo_type = update_enabled_repository_type(repository_type.to_s)
        end
        found_repo_type
      end

      def find_by(attribute, value)
        enabled_repository_types.values.find { |type| type.try(attribute) == value }
      end

      def find_repository_type(katello_label)
        enabled_repository_types.values.each do |repo_type|
          repo_type.content_types.each do |content_type|
            return repo_type if content_type.label == katello_label.to_s
          end
        end
        nil
      end

      def find_content_type(katello_label)
        enabled_repository_types.values.each do |repo_type|
          repo_type.content_types.each do |content_type|
            return content_type if content_type.label == katello_label.to_s
          end
        end
        nil
      end

      def model_class(pulp_service_class)
        enabled_repository_types.values.each do |repo_type|
          repo_type.content_types.each do |content_type|
            return content_type.model_class if (content_type.pulp2_service_class == pulp_service_class || content_type.pulp3_service_class == pulp_service_class)
          end
        end
      end

      def find_content_type!(katello_label)
        find_content_type(katello_label) || fail("Couldn't find content type #{katello_label}")
      end

      def enabled?(repository_type)
        find(repository_type).present?
      end

      def check_content_matches_repo_type!(repository, content_type)
        repo_content_types = repository.repository_type.content_types.collect { |type| type.label }
        unless repo_content_types.include?(content_type)
          fail _("Content type %{content_type} is incompatible with repositories of type %{repo_type}") %
                 { content_type: content_type, repo_type: repository.content_type }
        end
      end

      def generic_remote_options(opts = {})
        options = []
        repo_types = opts[:defined_only] ? defined_repository_types : enabled_repository_types
        repo_types.each do |_, type|
          if opts[:content_type]
            (options << type.generic_remote_options).flatten! if type.pulp3_service_class == Katello::Pulp3::Repository::Generic && type.id.to_s == opts[:content_type]
          else
            (options << type.generic_remote_options).flatten! if type.pulp3_service_class == Katello::Pulp3::Repository::Generic
          end
        end
        options
      end

      private

      def update_enabled_repository_type(repository_type)
        defined_repo_type = find_defined(repository_type.to_s)
        if defined_repo_type.present? && pulp3_plugin_installed?(repository_type.to_s)
          @enabled_repository_types[repository_type.to_s] = defined_repo_type
        end
      end

      def save_pulp_primary
        @pulp_primary = ::SmartProxy.unscoped.detect { |proxy| !proxy.setting(PULP3_FEATURE, 'mirror') }
      rescue ActiveRecord::StatementInvalid
        @pulp_primary = nil
      end
    end
  end
end
