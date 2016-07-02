module Katello
  class FileUnit < Katello::Model
    include Concerns::PulpDatabaseUnit

    self.table_name = 'katello_files'

    CONTENT_TYPE = Pulp::FileUnit::CONTENT_TYPE

    has_many :repositories, :through => :repository_files, :class_name => "Katello::Repository"
    has_many :repository_files, :class_name => "Katello::RepositoryFile", :dependent => :destroy, :inverse_of => :file, :foreign_key => :file_id

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :path, :complete_value => true
    scoped_search :on => :checksum
    scoped_search :in => :repositories, :on => :name, :rename => :repository, :complete_value => true

    def self.default_sort
      order(:name)
    end

    def self.repository_association_class
      RepositoryFile
    end

    def self.unit_id_field
      'file_id'
    end

    def update_from_json(json)
      custom_json = {}
      custom_json['checksum'] = json['checksum']
      custom_json['path'] = json['name']
      custom_json['name'] = File.basename(json['name'])
      self.update_attributes!(custom_json)
    end

    def self.total_for_repositories(repos)
      self.in_repositories(repos).uniq.count
    end
  end
end
