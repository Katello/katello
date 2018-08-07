module Katello
  class ModuleProfile < ApplicationRecord
    belongs_to :module_stream, class_name: "Katello::ModuleStream"
    has_many :rpms, class_name: "Katello::ModuleProfileRpm", dependent: :destroy
  end
end
