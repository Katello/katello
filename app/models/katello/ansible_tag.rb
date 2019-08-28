module Katello
  class AnsibleTag < ApplicationRecord
    self.table_name = 'katello_ansible_tags'

    has_many :ansible_collection_tags, :class_name => "Katello::AnsibleCollectionTag", :dependent => :delete_all
    has_many :ansible_collections, :through => :ansible_collection_tags
  end
end
