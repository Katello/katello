require 'rubygems/package'
require 'zlib'

module Katello
  class PuppetModule < Katello::Model
    include Concerns::PulpDatabaseUnit

    CONTENT_TYPE = "puppet_module".freeze

    has_many :content_view_puppet_environment_puppet_modules,
             :class_name => "Katello::ContentViewPuppetEnvironmentPuppetModule",
             :dependent => :destroy,
             :inverse_of => :puppet_module
    has_many :content_view_puppet_environments,
             :through => :content_view_puppet_environment_puppet_modules,
             :class_name => "Katello::ContentViewPuppetEnvironment"

    scoped_search :on => :id, :only_explicit => true
    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :author, :complete_value => true
    scoped_search :on => :version, :complete_value => true
    scoped_search :on => :summary

    validates :pulp_id, :presence => true
    validates :name, :presence => true
    validates :author, :presence => true

    before_save :set_sortable_version

    def self.latest_module(name, author, repositories)
      in_repositories(repositories).where(:name => name, :author => author).
        order(:sortable_version => :desc).first
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
      puppet_modules.each_with_object({}) do |puppet_module, result|
        repo = puppet_module.repositories.first

        if repo
          result[repo.id] ||= []
          result[repo.id] << puppet_module
        else
          fail _("Could not find Repository for module %s.") % puppet_module.name
        end
      end
    end

    private

    def set_sortable_version
      if version_changed? && !version.nil?
        self.sortable_version = Util::Package.sortable_version(version)
      end
    end
  end
end
