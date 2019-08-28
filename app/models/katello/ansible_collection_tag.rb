module Katello
  class AnsibleCollectionTag < ApplicationRecord
    self.table_name = 'katello_ansible_collection_tags'

    belongs_to :ansible_collection, :inverse_of => :ansible_collection_tags, :class_name => 'Katello::AnsibleCollection'
    belongs_to :tag, :inverse_of => :ansible_collection_tags, :class_name => 'Katello::AnsibleTag', :foreign_key => :ansible_tag_id
  end
end
