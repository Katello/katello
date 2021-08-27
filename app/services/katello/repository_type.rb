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
              :pulp3_skip_publication, :configuration_class, :partial_repo_path, :pulp3_api_class,
              :repositories_api_class, :api_class, :remotes_api_class, :repository_versions_api_class,
              :distributions_api_class, :remote_class, :repo_sync_url_class, :client_module_class,
              :distribution_class, :publication_class, :publications_api_class, :model_name, :model_version

    attr_accessor :metadata_publish_matching_check, :index_additional_data_proc
    attr_reader :id, :unique_content_per_repo

    def initialize(id)
      @id = id.to_sym
      allow_creation_by_user(true)
      @unique_content_per_repo = false
      @content_types = []
      @generic_remote_options = []
    end

    def set_unique_content_per_repo
      @unique_content_per_repo = true
    end

    def content_types
      @content_types.sort_by(&:priority)
    end

    def generic_remote_options
      @generic_remote_options.sort_by(&:name)
    end

    def content_types_to_index
      if SmartProxy.pulp_primary&.pulp3_repository_type_support?(self)
        # type.index being false supersedes type.index_on_pulp3 being true
        @content_types.select { |type| type.index && type.index_on_pulp3 }
      else
        @content_types.select { |type| type.index }
      end
    end

    def default_managed_content_type(label = nil)
      if label
        @default_managed_content_type_label = label.to_s
      else
        @content_types.find { |content_type| content_type.label == @default_managed_content_type_label }
      end
    end

    def content_type(model_class, options = {})
      @content_types ||= []
      @content_types << ContentType.new(options.merge(:model_class => model_class))
    end

    def generic_content_type(content_type, options = {})
      @content_types ||= []
      @content_types << GenericContentType.new(options.merge(:content_type => content_type))
    end

    def generic_remote_option(name, options = {})
      @generic_remote_options ||= []
      @generic_remote_options << GenericRemoteOption.new(options.merge(:name => name))
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
        :creatable => @allow_creation_by_user,
        :pulp3_support => SmartProxy.pulp_primary.pulp3_repository_type_support?(self)
      }
    end

    def inspect
      "RepositoryType[#{self.id}]"
    end

    def pulp3_api(smart_proxy)
      if pulp3_api_class == Katello::Pulp3::Api::Generic
        pulp3_api_class.new(smart_proxy, self)
      else
        pulp3_api_class ? pulp3_api_class.new(smart_proxy) : Katello::Pulp3::Api::Core.new(smart_proxy)
      end
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

    class GenericContentType < ContentType
      attr_accessor :pulp3_api, :pulp3_model, :content_type, :filename_key, :duplicates_allowed

      def initialize(options)
        self.model_class = options[:model_class]
        self.priority = options[:priority] || 99
        self.pulp3_service_class = options[:pulp3_service_class]
        self.index = options[:index].nil? ? true : options[:index]
        self.index_on_pulp3 = options[:index_on_pulp3].nil? ? true : options[:index_on_pulp3]
        self.uploadable = options[:uploadable] || false
        self.removable = options[:removable] || false
        self.pulp3_api = options[:pulp3_api]
        self.pulp3_model = options[:pulp3_model]
        self.content_type = options[:content_type]
        self.filename_key = options[:filename_key]
        self.duplicates_allowed = options[:duplicates_allowed]
      end

      def label
        self.content_type
      end
    end

    class GenericRemoteOption
      attr_accessor :name, :type, :description

      def initialize(options)
        self.name = options[:name]
        self.type = options[:type]
        self.description = options[:description]
      end
    end
  end
end
