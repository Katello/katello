module Katello
  class RepositoryTypeManager
    @repository_types = {}
    class << self
      private :new
      attr_reader :repository_types

      # Plugin constructor
      def register(id, &block)
        configured = SETTINGS[:katello][:content_types].nil? || SETTINGS[:katello][:content_types].with_indifferent_access[id]
        if find(id).blank? && configured
          repository_type = ::Katello::RepositoryType.new(id)
          repository_type.instance_eval(&block) if block_given?
          repository_types[id.to_s] = repository_type
        end
      end

      def creatable_repository_types
        repository_types.select do |repo_type, _|
          creatable_by_user?(repo_type)
        end
      end

      def enabled_content_types
        list = repository_types.values.map do |type|
          type.content_types.map(&:model_class).flatten.map { |ct| ct::CONTENT_TYPE }
        end
        list.flatten
      end

      def indexable_content_types
        repository_types.
                  values.
                  map(&:content_types_to_index).
                  flatten
      end

      def creatable_by_user?(repository_type)
        return false unless (type = find(repository_type))
        type.allow_creation_by_user
      end

      def removable_content_types
        list = @repository_types.values.map do |type|
          type.content_types.select(&:removable)
        end
        list.flatten
      end

      def uploadable_content_types
        list = @repository_types.values.map do |type|
          type.content_types.select(&:uploadable)
        end
        list.flatten
      end

      def find(repository_type)
        repository_types[repository_type.to_s]
      end

      def find_by(attribute, value)
        repository_types.values.find { |type| type.try(attribute) == value }
      end

      def find_repository_type(katello_label)
        repository_types.values.each do |repo_type|
          repo_type.content_types.each do |content_type|
            return repo_type if content_type.label == katello_label.to_s
          end
        end
        nil
      end

      def find_content_type(katello_label)
        repository_types.values.each do |repo_type|
          repo_type.content_types.each do |content_type|
            return content_type if content_type.label == katello_label.to_s
          end
        end
        nil
      end

      def model_class(pulp_service_class)
        repository_types.values.each do |repo_type|
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
    end
  end
end
