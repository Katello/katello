module Katello
  class OstreeBranch < Katello::Model
    include Concerns::PulpDatabaseUnit

    has_many :repository_ostree_branches, :dependent => :destroy, :class_name => 'Katello::RepositoryOstreeBranch'
    has_many :repositories, :through => :repository_ostree_branches, :inverse_of => :ostree_branches

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :version, :complete_value => true
    scoped_search :on => :commit, :complete_value => true
    scoped_search :on => :pulp_id, :complete_value => true, :rename => :uuid

    CONTENT_TYPE = "ostree".freeze

    def self.repository_association_class
      RepositoryOstreeBranch
    end
  end
end
