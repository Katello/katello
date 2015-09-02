module Katello
  module Pulp
    class Erratum < PulpContentUnit
      CONTENT_TYPE = "erratum"

      def self.unit_handler
        Katello.pulp_server.extensions.errata
      end
    end
  end
end
