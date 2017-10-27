module Katello
  module Pulp
    class Erratum < PulpContentUnit
      PULP_SELECT_FIELDS = %w(errata_id).freeze
      CONTENT_TYPE = "erratum".freeze

      def self.unit_handler
        Katello.pulp_server.extensions.errata
      end
    end
  end
end
