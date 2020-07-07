module Katello
  class ErratumCve < Katello::Model
    belongs_to :erratum, :inverse_of => :cves, :class_name => 'Katello::Erratum'

    apipie :class, desc: 'A class representing Erratum CVE object' do
      name 'Erratum CVE'
      refs 'ErratumCve'
      sections only: %w[all additional]
      property :erratum, 'Erratum', desc: 'Returns Erratum object associated with this CVE'
      property :cve_id, String, desc: 'Returns CVE identifier, e.g. "CVE-2223-0322"'
      property :href, String, desc: 'Returns link to the CVE, e.g. https://www.redhat.com/security/data/cve/CVE-2233-0322.html'
    end
    class Jail < ::Safemode::Jail
      allow :erratum, :cve_id, :href
    end
  end
end
