module Katello
  class ErratumPackage < Katello::Model
    self.include_root_in_json = false

    belongs_to :erratum, :inverse_of => :packages, :class_name => 'Katello::Erratum'
  end
end
