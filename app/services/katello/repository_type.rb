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

    def_field :allow_creation_by_user, :service_class, :pulp3_service_class, :pulp3_plugin,
              :pulp3_skip_publication, :pulp3_api_class

    attr_accessor :metadata_publish_matching_check, :index_additional_data_proc
    attr_reader :id, :unique_content_per_repo

    def initialize(id)
      @id = id.to_sym
      allow_creation_by_user(true)
      @unique_content_per_repo = false
    end

    def set_unique_content_per_repo
      @unique_content_per_repo = true
    end

    def content_types
      @content_types.sort_by(&:priority)
    end

    def content_types_to_index
      if SmartProxy.pulp_master.pulp3_repository_type_support?(self)
        # type.index being false supersedes type.index_on_pulp3 being true
        @content_types.select { |type| type.index && type.index_on_pulp3 }
      else
        @content_types.select { |type| type.index }
      end
    end

    def default_managed_content_type(model_class = nil)
      if model_class
        @default_managed_content_type_class = model_class
      else
        @content_types.find { |content_type| content_type.model_class == @default_managed_content_type_class }
      end
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
      attr_accessor :model_class, :priority, :pulp2_service_class, :pulp3_service_class, :index, :uploadable, :removable, :index_on_pulp3

      def initialize(options)
        self.model_class = options[:model_class]
        self.priority = options[:priority] || 99
        self.pulp2_service_class = options[:pulp2_service_class]
        self.pulp3_service_class = options[:pulp3_service_class]
        self.index = options[:index].nil? ? true : options[:index]
        self.index_on_pulp3 = options[:index_on_pulp3].nil? ? true : options[:index_on_pulp3]
        self.uploadable = options[:uploadable] || false
        self.removable = options[:removable] || false
      end

      def label
        self.model_class::CONTENT_TYPE
      end
    end
  end
end
