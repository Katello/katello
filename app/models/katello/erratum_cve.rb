module Katello
  class ErratumCve < Katello::Model
    belongs_to :erratum, :inverse_of => :cves, :class_name => 'Katello::Erratum'

    class Jail < ::Safemode::Jail
      allow :erratum, :cve_id, :href
    end
  end
end
