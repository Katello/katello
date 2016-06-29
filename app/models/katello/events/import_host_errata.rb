module Katello
  module Events
    class ImportHostErrata
      EVENT_TYPE = 'import_host_errata'.freeze

      def initialize(object_id)
        @host = ::Host.find_by_id(object_id)
        fail "Host not found for ID #{object_id}" if @host.nil?
      end

      def run
        @host.content_facet.try(:import_applicability, true) if @host
      end
    end
  end
end
