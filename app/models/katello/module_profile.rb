module Katello
  class ModuleProfile < Katello::Model
    belongs_to :module_stream, class_name: "Katello::ModuleStream", inverse_of: :profiles
    has_many :rpms, class_name: "Katello::ModuleProfileRpm", dependent: :destroy, inverse_of: :module_profile
  end
end
