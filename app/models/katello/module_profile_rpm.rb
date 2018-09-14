module Katello
  class ModuleProfileRpm < Katello::Model
    belongs_to :module_profile, class_name: "Katello::ModuleProfile", inverse_of: :rpms
  end
end
