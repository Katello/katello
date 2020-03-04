module Katello
  class ModuleStreamRpm < Katello::Model
    belongs_to :module_stream, class_name: "Katello::ModuleStream", inverse_of: :module_stream_rpms
    belongs_to :rpm, class_name: "Katello::Rpm", inverse_of: :module_stream_rpms
  end
end
