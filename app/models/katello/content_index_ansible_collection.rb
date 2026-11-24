module Katello
  class ContentIndexAnsibleCollection < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :content_index, :inverse_of => :content_index_ansible_collections, :class_name => 'Katello::ContentIndex'
    belongs_to :ansible_collection, :class_name => 'Katello::AnsibleCollection', :inverse_of => :content_index_ansible_collections
  end
end
