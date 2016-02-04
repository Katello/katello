module Katello
  class ErratumCve < Katello::Model
    self.include_root_in_json = false

    belongs_to :erratum, :inverse_of => :cves, :class_name => 'Katello::Erratum'
  end
end
