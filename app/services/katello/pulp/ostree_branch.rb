module Katello
  module Pulp
    class OstreeBranch < PulpContentUnit
      CONTENT_TYPE = "ostree".freeze

      def update_model(model)
        model.update_attributes(:name => backend_data[:branch],
                          :version => backend_data[:metadata][:version],
                          :commit => backend_data[:commit],
                          :version_date => backend_data[:_created].to_datetime
                         )
      end
    end
  end
end
