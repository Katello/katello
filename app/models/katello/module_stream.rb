module Katello
  class ModuleStream < Katello::Model
    include Concerns::PulpDatabaseUnit
    include ScopedSearchExtensions
    has_many :repository_module_streams, class_name: "Katello::RepositoryModuleStream",
      dependent: :destroy, inverse_of: :module_stream
    has_many :repositories, through: :repository_module_streams, class_name: "Katello::Repository"
    has_many :profiles, class_name: "Katello::ModuleProfile", dependent: :destroy, inverse_of: :module_stream
    has_many :artifacts, class_name: "Katello::ModuleStreamArtifact", dependent: :destroy, inverse_of: :module_stream

    scoped_search on: :name, complete_value: true
    scoped_search on: :uuid, complete_value: true
    scoped_search on: :stream, complete_value: true
    scoped_search on: :version, complete_value: true
    scoped_search on: :context, complete_value: true
    scoped_search on: :arch, complete_value: true
    scoped_search on: :host, rename: :host,
                  only_explicit: true,
                  ext_method: :find_by_host_name,
                  complete_value: false

    scoped_search on: :module_spec, rename: :module_spec,
                   only_explicit: true,
                   ext_method: :find_by_module_spec,
                   complete_value: false,
                   operators: ["=", "~"]

    CONTENT_TYPE = Pulp::ModuleStream::CONTENT_TYPE
    MODULE_STREAM_DEFAULT_CONTENT_TYPE = "modulemd_defaults".freeze

    def self.default_sort
      order(:name)
    end

    def self.repository_association_class
      RepositoryModuleStream
    end

    def update_from_json(json)
      shared_attributes = json.keys & self.class.column_names
      shared_json = json.select { |key, _v| shared_attributes.include?(key) }
      self.update_attributes!(shared_json)

      create_stream_artifacts(json['artifacts']) if json.key?('artifacts')
      create_profiles(json['profiles']) if json.key?('profiles')
    end

    def create_stream_artifacts(artifacts)
      artifacts.each do |name|
        self.artifacts.where(name: name).first_or_create!
      end
    end

    def create_profiles(profiles)
      profiles.select do |profile, rpms|
        profile = self.profiles.where(name: profile).first_or_create!
        rpms.each do |rpm|
          profile.rpms.where(name: rpm).first_or_create!
        end
      end
    end

    def library_repositories
      self.repositories.where(library_instance: nil)
    end

    def self.available_for_hosts(hosts)
      where("#{table_name}.id" => ::Katello::ModuleStream.joins(repositories: :content_facets).
            select("#{table_name}.id").
            merge(::Katello::Host::ContentFacet.where(host_id: hosts)))
    end

    def module_spec
      # NAME:STREAM:VERSION:CONTEXT:ARCH
      items = []
      ["name", "stream", "version", "context", "arch"].each do |item|
        if attributes[item]
          items << attributes[item]
        else
          break
        end
      end
      items.join(":")
    end

    def self.parse_module_spec(module_spec)
      # NAME:STREAM:VERSION:CONTEXT:ARCH/PROFILE
      spec = module_spec.split("/").first
      name, stream, version, context, arch = spec.split(":")
      {:name => name, :stream => stream, :version => version, :context => context, :arch => arch}.compact
    end

    def self.find_by_host_name(_key, operator, value)
      conditions = sanitize_sql_for_conditions(["#{::Host::Managed.table_name}.name #{operator} ?", value_to_sql(operator, value)])
      hosts = ::Host::Managed.authorized("view_hosts").where(conditions).select(:id)
      if hosts.empty?
        { :conditions => "1=0" }
      else
        { :conditions => "#{::Katello::ModuleStream.table_name}.id in (#{available_for_hosts(hosts).select(:id).to_sql})" }
      end
    end

    def self.find_by_module_spec(_key, _operator, value)
      spec = parse_module_spec(value)
      if spec.empty?
        { :conditions => "1=0" }
      else
        { :conditions => "#{::Katello::ModuleStream.table_name}.id in (#{select(:id).where(spec).to_sql})" }
      end
    end
  end
end
