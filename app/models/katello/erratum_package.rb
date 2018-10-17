module Katello
  class ErratumPackage < Katello::Model
    belongs_to :erratum, :inverse_of => :packages, :class_name => 'Katello::Erratum'
    has_many :module_stream_errata_packages, class_name: "Katello::ModuleStreamErratumPackage", dependent: :destroy, inverse_of: :erratum_package
    has_many :module_streams, class_name: "Katello::ModuleStream", :through => :module_stream_errata_packages

    def self.non_module_stream_packages
      where.not(:id => Katello::ModuleStreamErratumPackage.select(:erratum_package_id))
    end
  end
end
