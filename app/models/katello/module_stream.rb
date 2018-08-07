module Katello
  class ModuleStream < ApplicationRecord
    include Concerns::PulpDatabaseUnit
    has_many :repository_module_stream, class_name: "Katello::RepositoryModuleStream",
      dependent: :destroy, inverse_of: :module_stream
    has_many :repositories, through: :repository_module_stream, class_name: "Katello::Repository"
    has_many :profiles, class_name: "Katello::ModuleProfile", dependent: :destroy
    has_many :rpms, class_name: "Katello::ModuleStreamRpm", dependent: :destroy

    CONTENT_TYPE = 'modulemd'.freeze

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

      create_stream_rpms(json['artifacts']) if json.key?('artifacts')
      create_profiles(json['profiles']) if json.key?('profiles')
    end

    def create_stream_rpms(rpms)
      rpms.each do |nvra|
        self.rpms.where(nvra: nvra).first_or_create!
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
