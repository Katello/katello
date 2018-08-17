module Katello
  class ModuleStream < ApplicationRecord
    include Concerns::PulpDatabaseUnit
    has_many :repository_module_streams, class_name: "Katello::RepositoryModuleStream",
      dependent: :destroy, inverse_of: :module_stream
    has_many :repositories, through: :repository_module_streams, class_name: "Katello::Repository"
    has_many :profiles, class_name: "Katello::ModuleProfile", dependent: :destroy
    has_many :artifacts, class_name: "Katello::ModuleStreamArtifact", dependent: :destroy

    scoped_search on: :name, complete_value: true
    scoped_search on: :uuid, complete_value: true
    scoped_search on: :stream, complete_value: true
    scoped_search on: :version, complete_value: true
    scoped_search on: :context, complete_value: true
    scoped_search on: :arch, complete_value: true
    scoped_search relation: :repositories, on: :name, rename: :repository, complete_value: true
    scoped_search relation: :repositories, on: :id, rename: :repository_id, complete_value: true

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
  end
end
