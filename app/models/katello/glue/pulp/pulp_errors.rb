module Katello
  module Glue
    module Pulp
      module PulpErrors
        class ServiceUnavailable < HttpErrors::ServiceUnavailable; end
      end
    end
  end
end
