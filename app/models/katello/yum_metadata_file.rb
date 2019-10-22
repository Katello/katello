module Katello
  class YumMetadataFile < Katello::Model
    include Concerns::PulpDatabaseUnit
    include ScopedSearchExtensions
    belongs_to :repository, :inverse_of => :yum_metadata_files, :class_name => "Katello::Repository"
    CONTENT_TYPE = "yum_repo_metadata_file".freeze

    def self.import_for_repository(repository)
      ::Katello::YumMetadataFile.where(:repository_id => repository).destroy_all
      super(repository)
    end

    # yum metadata files are many-to-many in Pulp 3
    def repositories
      [repository]
    end

    def self.completer_scope_options
      {"#{Katello::Repository.table_name}" => lambda { |repo_class| repo_class.yum_type } }
    end
  end
end
