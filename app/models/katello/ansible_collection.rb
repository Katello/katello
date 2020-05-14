module Katello
  class AnsibleCollection < Katello::Model
    include Concerns::PulpDatabaseUnit

    self.table_name = 'katello_ansible_collections'
    CONTENT_TYPE = 'ansible collection'.freeze

    has_many :ansible_collection_tags, :class_name => "Katello::AnsibleCollectionTag", :dependent => :delete_all
    has_many :tags, :through => :ansible_collection_tags

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :namespace, :complete_value => true, :rename => :author
    scoped_search :on => :version, :complete_value => true
    scoped_search :on => :checksum, :complete_value => true
    scoped_search :on => :name, :complete_value => true, :relation => :tags, :rename => :tag

    def self.default_sort
      order(:name)
    end

    def self.unit_id_field
      'ansible_collection_id'
    end

    def self.total_for_repositories(repos)
      self.in_repositories(repos).count
    end
  end
end
