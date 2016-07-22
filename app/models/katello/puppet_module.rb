require 'rubygems/package'
require 'zlib'

module Katello
  class PuppetModule < Katello::Model
    include Concerns::PulpDatabaseUnit

    CONTENT_TYPE = Pulp::PuppetModule::CONTENT_TYPE

    has_many :repositories, :through => :repository_puppet_modules, :class_name => "Katello::Repository"
    has_many :repository_puppet_modules, :class_name => "Katello::RepositoryPuppetModule", :dependent => :destroy, :inverse_of => :puppet_module

    has_many :content_view_puppet_environments,
             :through => :content_view_puppet_environment_puppet_modules,
             :class_name => "Katello::ContentViewPuppetEnvironment"
    has_many :content_view_puppet_environment_puppet_modules,
             :class_name => "Katello::ContentViewPuppetEnvironmentPuppetModule",
             :dependent => :destroy,
             :inverse_of => :puppet_module

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :author, :complete_value => true
    scoped_search :on => :version, :complete_value => true
    scoped_search :on => :summary

    validates :uuid, :presence => true
    validates :name, :presence => true
    validates :author, :presence => true

    before_save :set_sortable_version

    def self.latest_module(name, author, repositories)
      in_repositories(repositories).where(:name => name, :author => author).
        order(:sortable_version => :desc).first
    end

    def self.repository_association_class
      RepositoryPuppetModule
    end

    def self.parse_metadata(filepath)
      metadata = nil

      tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(filepath))
      tar_extract.rewind # The extract has to be rewinded after every iteration
      tar_extract.each do |entry|
        next unless entry.file? && entry.full_name =~ %r{\A[^/]+/metadata.json\z}
        metadata = entry.read
      end

      if metadata
        return JSON.parse(metadata).with_indifferent_access
      else
        fail Katello::Errors::InvalidPuppetModuleError, _("Invalid puppet module. Please make sure the puppet module contains a metadata.json file and is properly compressed.")
      end
    rescue Zlib::GzipFile::Error, Gem::Package::TarInvalidError
      raise Katello::Errors::InvalidPuppetModuleError, _("Could not unarchive puppet module. Please make sure the puppet module has been compressed properly.")
    ensure
      tar_extract.close if tar_extract
    end

    def self.group_by_repoid(puppet_modules)
      puppet_modules.flatten.each_with_object({}) do |puppet_module, result|
        repo = puppet_module.repositories.first

        if repo
          result[repo.pulp_id] ||= []
          result[repo.pulp_id] << puppet_module.uuid
        else
          fail _("Could not find Repository for module %s.") % puppet_module.name
        end
      end
    end

    def update_from_json(json)
      keys = %w(name author title version summary)
      custom_json = json.clone.delete_if { |key, _value| !keys.include?(key) }
      self.update_attributes!(custom_json)
    end

    private

    def set_sortable_version
      if version_changed? && !version.nil?
        self.sortable_version = Util::Package.sortable_version(version)
      end
    end
  end
end
