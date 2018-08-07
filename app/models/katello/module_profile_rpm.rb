module Katello
  class ModuleProfileRpm < ApplicationRecord
    belongs_to :module_profile, class_name: "Katello::ModuleProfile"
  end
end
