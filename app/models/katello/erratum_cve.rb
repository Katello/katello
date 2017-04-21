module Katello
  class ErratumCve < Katello::Model
    belongs_to :erratum, :inverse_of => :cves, :class_name => 'Katello::Erratum'
  end
end
