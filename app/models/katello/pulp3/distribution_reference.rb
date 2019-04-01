module Katello
  module Pulp3
    class DistributionReference < Katello::Model
      belongs_to :root_repository, :class_name => 'Katello::RootRepository'
    end
  end
end
