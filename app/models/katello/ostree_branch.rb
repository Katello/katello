module Katello
  class OstreeBranch < Katello::Model
    include Concerns::PulpDatabaseUnit

    has_many :repository_ostree_branches, :dependent => :destroy
    has_many :repositories, :through => :repository_ostree_branches, :inverse_of => :ostree_branches

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :version, :complete_value => true
    scoped_search :on => :commit, :complete_value => true
    scoped_search :on => :uuid, :complete_value => true
    scoped_search :on => :version_date, :complete_value => true, :rename => :created
    scoped_search :in => :repositories, :on => :name, :rename => :repository, :complete_value => true

    CONTENT_TYPE = Pulp::OstreeBranch::CONTENT_TYPE

    def self.repository_association_class
      RepositoryOstreeBranch
    end

    def update_from_json(json)
      update_attributes(:name => json[:branch],
                        :version => json[:metadata][:version],
                        :commit => json[:commit],
                        :version_date => json["_created"].to_datetime
                       )
    end
  end
end
