module Katello
  module Pulp
    class OstreeBranch < PulpContentUnit
      CONTENT_TYPE = "ostree".freeze

      def update_model(model)
        model.update(:name => backend_data[:branch],
                          :version => backend_data[:metadata][:version],
                          :commit => backend_data[:commit]
                         )
      end
    end
  end
end
