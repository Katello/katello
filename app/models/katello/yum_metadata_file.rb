module Katello
  class YumMetadataFile < Katello::Model
    include Concerns::PulpDatabaseUnit
    include ScopedSearchExtensions
    belongs_to :repository, :inverse_of => :yum_metadata_files, :class_name => "Katello::Repository"
    CONTENT_TYPE = Pulp::YumMetadataFile::CONTENT_TYPE

    def update_from_json(json)
      shared_attributes = json.keys & self.class.column_names
      shared_json = json.select { |key, _v| shared_attributes.include?(key) }
      repo = ::Katello::Repository.find_by(:pulp_id => json['repo_id']).try(:id)
      self.update_attributes!(shared_json.merge(repository_id: repo))
    end

    def self.import_for_repository(repository)
      ::Katello::YumMetadataFile.where(:repository_id => repository).destroy_all
      super(repository, true)
    end

    def self.manage_repository_association
      false
    end

    # yum metadata file only has one repo
    def repositories
      [repository]
    end

    def self.completer_scope_options
      {"#{Katello::Repository.table_name}" => lambda { |repo_class| repo_class.yum_type } }
    end
  end
end
