module Katello
  # Preloads the per-row errata payload for a whole page, alongside the host counts.
  class ErrataListDetails < HostCountsDetails
    def self.preloads
      [:cves, :bugzillas]
    end

    def present(unit)
      ErrataListPresenter.new(unit, self)
    end

    def package_nvreas(unit_id)
      package_nvreas_by_erratum.fetch(unit_id, [])
    end

    def module_streams(unit_id)
      module_streams_by_erratum.fetch(unit_id, [])
    end

    private

    def package_nvreas_by_erratum
      @package_nvreas_by_erratum ||= model.package_nvreas_by_erratum(unit_ids)
    end

    def module_streams_by_erratum
      @module_streams_by_erratum ||= model.module_streams_by_erratum(unit_ids)
    end
  end
end
