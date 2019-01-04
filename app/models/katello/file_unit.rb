module Katello
  class FileUnit < Katello::Model
    include Concerns::PulpDatabaseUnit

    self.table_name = 'katello_files'

    CONTENT_TYPE = 'file'.freeze

    has_many :repository_files, :class_name => "Katello::RepositoryFile", :dependent => :destroy, :inverse_of => :file, :foreign_key => :file_id
    has_many :repositories, :through => :repository_files, :class_name => "Katello::Repository"

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :path, :complete_value => true
    scoped_search :on => :checksum

    def self.default_sort
      order(:name)
    end

    def self.repository_association_class
      RepositoryFile
    end

    def self.unit_id_field
      'file_id'
    end

    def self.total_for_repositories(repos)
      self.in_repositories(repos).count
    end
  end
end
