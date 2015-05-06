module Katello
  class CapsuleLifecycleEnvironment < Katello::Model
    validates_lengths_from_database
    validates :lifecycle_environment_id,
              :uniqueness => { :scope => :capsule_id,
                               :message => _("is already attached to the capsule") }

    belongs_to :capsule, :class_name => "::SmartProxy", :inverse_of => :capsule_lifecycle_environments
    belongs_to :lifecycle_environment, :class_name => "Katello::KTEnvironment", :inverse_of => :capsule_lifecycle_environments
  end
end
