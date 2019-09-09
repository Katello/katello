module Katello
  class OstreeBranch < Katello::Model
    include Concerns::PulpDatabaseUnit

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :version, :complete_value => true
    scoped_search :on => :commit, :complete_value => true
    scoped_search :on => :pulp_id, :complete_value => true, :rename => :uuid

    CONTENT_TYPE = "ostree".freeze
  end
end
