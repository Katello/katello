module Katello
  class ErratumDebPackage < Katello::Model
    belongs_to :erratum, :inverse_of => :deb_packages, :class_name => 'Katello::Erratum'
  end
end
