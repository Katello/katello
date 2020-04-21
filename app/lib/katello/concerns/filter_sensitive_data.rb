module Katello
  module Concerns
    module FilterSensitiveData
      extend ActiveSupport::Concern

      # This is called at both the instance and class levels, so must be available as both.
      def filter_sensitive_data(payload)
        self.class.filter_sensitive_data(payload)
      end

      class_methods do
        def filter_sensitive_data(payload)
          payload.gsub(/-----BEGIN RSA PRIVATE KEY-----[\s\S]*-----END RSA PRIVATE KEY-----/, '[private key filtered]')
        end
      end
    end
  end
end
