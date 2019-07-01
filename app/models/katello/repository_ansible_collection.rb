module Katello
  class RepositoryAnsibleCollection < Katello::Model
    belongs_to :repository, inverse_of: :repository_ansible_collections, class_name: 'Katello::Repository'
    belongs_to :ansible_collection, inverse_of: :repository_ansible_collections, class_name: 'Katello::AnsibleCollection'
  end
end
