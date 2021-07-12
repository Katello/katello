module Katello
  class GenericContentUnit < Katello::Model
    self.table_name = 'katello_generic_content_units'
    include Concerns::PulpDatabaseUnit

    CONTENT_TYPE = 'generic_content_unit'.freeze

    def self.default_sort
      order(:name)
    end

    def self.total_for_repositories(repos)
      self.in_repositories(repos).count
    end
  end
end
