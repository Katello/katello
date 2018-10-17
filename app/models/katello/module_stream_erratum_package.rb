module Katello
  class ModuleStreamErratumPackage < Katello::Model
    belongs_to :module_stream, class_name: "Katello::ModuleStream", inverse_of: :module_stream_errata_packages
    belongs_to :erratum_package, class_name: "Katello::ErratumPackage", inverse_of: :module_stream_errata_packages
  end
end
