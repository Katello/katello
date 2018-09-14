module Katello
  class ModuleStreamArtifact < Katello::Model
    belongs_to :module_stream, class_name: "Katello::ModuleStream", inverse_of: :artifacts
  end
end
