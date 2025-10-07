require 'pulp_rpm_client'

# Monkey patch to allow nil values for deprecated gpgcheck and repo_gpgcheck fields
# These fields were removed in pulp_rpm 3.30.0 but older Pulp versions return null
# The new bindings don't allow nil, causing ArgumentError when deserializing responses
[PulpRpmClient::RpmRpmRepositoryResponse, PulpRpmClient::RpmRpmPublicationResponse].each do |klass|
  klass.class_eval do
    # Custom attribute writer method with validation
    # @param [Object] gpgcheck Value to be assigned
    def gpgcheck=(gpgcheck)
      # Allow nil for deprecated field - monkey patch here
      if !gpgcheck.nil? && gpgcheck > 1
        fail ArgumentError, 'invalid value for "gpgcheck", must be smaller than or equal to 1.'
      end

      if !gpgcheck.nil? && gpgcheck < 0
        fail ArgumentError, 'invalid value for "gpgcheck", must be greater than or equal to 0.'
      end

      @gpgcheck = gpgcheck
    end

    # Custom attribute writer method with validation
    # @param [Object] repo_gpgcheck Value to be assigned
    def repo_gpgcheck=(repo_gpgcheck)
      # Allow nil for deprecated field - monkey patch here
      if !repo_gpgcheck.nil? && repo_gpgcheck > 1
        fail ArgumentError, 'invalid value for "repo_gpgcheck", must be smaller than or equal to 1.'
      end

      if !repo_gpgcheck.nil? && repo_gpgcheck < 0
        fail ArgumentError, 'invalid value for "repo_gpgcheck", must be greater than or equal to 0.'
      end

      @repo_gpgcheck = repo_gpgcheck
    end
  end
end
