module Katello
  module Pulp3
    class DistributionReference < Katello::Model
      belongs_to :repository, :class_name => 'Katello::Repository'
    end
  end
end
