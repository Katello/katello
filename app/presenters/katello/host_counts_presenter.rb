module Katello
  # Wraps a content unit in a list response so its host counts come from the
  # page preload instead of one query per row.
  class HostCountsPresenter < SimpleDelegator
    def initialize(unit, details)
      @details = details
      super(unit)
    end

    def hosts_available_count(_org_id = nil)
      @details.hosts_available_count(id)
    end

    def hosts_applicable_count(_org_id = nil)
      @details.hosts_applicable_count(id)
    end

    protected

    attr_reader :details
  end
end
