module Katello
  class FileUnit < Katello::Model
    self.table_name = 'katello_files'
    include Concerns::PulpDatabaseUnit

    CONTENT_TYPE = 'file'.freeze

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :path, :complete_value => true
    scoped_search :on => :checksum

    def self.default_sort
      order(:name)
    end

    def filename
      path
    end

    def self.total_for_repositories(repos)
      self.in_repositories(repos).count
    end
  end
end
