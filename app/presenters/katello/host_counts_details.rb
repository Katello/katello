module Katello
  # Preloads the host counts that content unit list responses serialize for a
  # whole page at once.
  class HostCountsDetails
    def self.load(model, records, organization_id: nil)
      new(model, records.map(&:id), organization_id: organization_id)
    end

    # Returns rows that read their page-level data from the preload.
    def self.wrap(model, records, organization_id: nil)
      return records unless usable_for?(model)

      details = load(model, records, organization_id: organization_id)
      records.map { |record| details.present(record) }
    end

    def self.preloads
      []
    end

    def self.usable_for?(model)
      model.respond_to?(:applicable_host_counts)
    end

    def present(unit)
      HostCountsPresenter.new(unit, self)
    end

    def initialize(model, unit_ids, organization_id: nil)
      @model = model
      @unit_ids = unit_ids
      @organization_id = organization_id
    end

    def hosts_applicable_count(unit_id)
      hosts_applicable_counts[unit_id].to_i
    end

    def hosts_available_count(unit_id)
      hosts_available_counts[unit_id].to_i
    end

    private

    attr_reader :model, :unit_ids, :organization_id

    def hosts_applicable_counts
      @hosts_applicable_counts ||= model.applicable_host_counts(unit_ids, organization_id)
    end

    def hosts_available_counts
      @hosts_available_counts ||= model.available_host_counts(unit_ids, organization_id)
    end
  end
end
