module Katello
  module Pulp3
    class RepositoryReference < Katello::Model
      has_many :publisher_references, :class_name => 'Katello::Pulp3::PublisherReference', :foreign_key => 'repository_reference_id'
    end
  end
end
