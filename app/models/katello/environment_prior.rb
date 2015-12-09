module Katello
  class EnvironmentPrior < Katello::Model
    belongs_to :env, :class_name => "Katello::KTEnvironment", :inverse_of => :env_priors, :foreign_key => :environment_id
    belongs_to :env_prior, :class_name => "Katello::KTEnvironment", :inverse_of => :env_successors, :foreign_key => :prior_id
    validates :prior_id, :presence => true
  end
end
