module Katello
  class ModuleStreamArtifact < ApplicationRecord
    belongs_to :module_stream, class_name: "Katello::ModuleStream"
  end
end
