module Katello
  class RepositoryType
    class << self
      def def_field(*names)
        class_eval do
          names.each do |name|
            define_method(name) do |*args|
              args.empty? ? instance_variable_get("@#{name}") : instance_variable_set("@#{name}", *args)
            end
          end
        end
      end
    end

    def_field :allow_creation_by_user, :service_class, :pulp3_service_class, :pulp3_plugin
    attr_accessor :metadata_publish_matching_check, :index_additional_data_proc
    attr_reader :id

    def initialize(id)
      @id = id.to_sym
      allow_creation_by_user(true)
    end

    def content_types
      @content_types.sort_by(&:priority)
    end

    def content_types_to_index
      @content_types.select { |type| type.index }
    end

    def user_removable_content_types
      @content_types.select { |type| type.user_removable }
    end

    def content_type(model_class, options = {})
      @content_types ||= []
      @content_types << ContentType.new(options.merge(:model_class => model_class))
    end

    def prevent_unneeded_metadata_publish
      self.metadata_publish_matching_check = true
    end

    def index_additional_data(&block)
      self.index_additional_data_proc = block
    end

    def <=>(other)
      self.id.to_s <=> other.id.to_s
    end

    def as_json(_options = {})
      {
        :name => self.id.to_s,
        :id => self.id,
        :creatable => @allow_creation_by_user
      }
    end

    class ContentType
      attr_accessor :model_class, :priority, :pulp2_service_class, :pulp3_service_class, :index, :user_removable

      def initialize(options)
        self.model_class = options[:model_class]
        self.priority = options[:priority] || 99
        self.pulp2_service_class = options[:pulp2_service_class]
        self.pulp3_service_class = options[:pulp3_service_class]
        self.index = options[:index].nil? ? true : options[:index]
        self.user_removable = options[:user_removable] || false
      end
    end
  end
end
