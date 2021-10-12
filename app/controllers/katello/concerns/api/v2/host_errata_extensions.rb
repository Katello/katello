module Katello
  module Concerns
    module Api::V2::HostErrataExtensions
      include Api::V2::BulkExtensions

      def find_bulk_errata_ids(hosts, bulk_errata_ids)
        errata = find_bulk_items(bulk_params: bulk_errata_ids,
                                 model_scope: ::Katello::Erratum.installable_for_hosts(hosts),
                                 key: :errata_id)
        errata.pluck(:errata_id)
      end
    end
  end
end
