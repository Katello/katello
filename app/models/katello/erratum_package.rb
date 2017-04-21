module Katello
  class ErratumPackage < Katello::Model
    belongs_to :erratum, :inverse_of => :packages, :class_name => 'Katello::Erratum'
  end
end
