# Monkey-patch PythonPythonRemote to skip provenance field for backwards compatibility
# with older Pulp versions (< 3.90) that don't support this field.
#
# Background:
# The provenance field was added in pulp_python 3.20+ (Pulpcore 3.90+) but is not
# recognized by older Pulp versions like 3.85. When syncing from a Katello server
# with newer Pulp client gems to a capsule running Pulp 3.85, the provenance field
# causes a 400 error: {"provenance":["Unexpected field"]}
#
# This monkey patch removes the provenance field from the PythonPythonRemote
# initializer to ensure compatibility when creating remotes on older Pulp instances.

require 'pulp_python_client'

PulpPythonClient::PythonPythonRemote.class_eval do
  # Initializes the object
  # @param [Hash] attributes Model attributes in the form of hash
  def initialize(attributes = {})
    if (!attributes.is_a?(Hash))
      fail ArgumentError, "The input argument (attributes) must be a hash in `PulpPythonClient::PythonPythonRemote` initialize method"
    end

    # Remove provenance field for backwards compatibility with Pulp < 3.90
    # This field was added in pulp_python 3.20+ but is not recognized by older Pulp versions
    attributes = attributes.except(:provenance, 'provenance')

    # check to see if the attribute exists and convert string to symbol for hash key
    attributes = attributes.each_with_object({}) { |(k, v), h|
      if (!self.class.attribute_map.key?(k.to_sym))
        fail ArgumentError, "`#{k}` is not a valid attribute in `PulpPythonClient::PythonPythonRemote`. Please check the name to make sure it's valid. List of attributes: " + self.class.attribute_map.keys.inspect
      end
      h[k.to_sym] = v
    }

    if attributes.key?(:'name')
      self.name = attributes[:'name']
    end

    if attributes.key?(:'url')
      self.url = attributes[:'url']
    end

    if attributes.key?(:'ca_cert')
      self.ca_cert = attributes[:'ca_cert']
    end

    if attributes.key?(:'client_cert')
      self.client_cert = attributes[:'client_cert']
    end

    if attributes.key?(:'client_key')
      self.client_key = attributes[:'client_key']
    end

    if attributes.key?(:'tls_validation')
      self.tls_validation = attributes[:'tls_validation']
    end

    if attributes.key?(:'proxy_url')
      self.proxy_url = attributes[:'proxy_url']
    end

    if attributes.key?(:'proxy_username')
      self.proxy_username = attributes[:'proxy_username']
    end

    if attributes.key?(:'proxy_password')
      self.proxy_password = attributes[:'proxy_password']
    end

    if attributes.key?(:'username')
      self.username = attributes[:'username']
    end

    if attributes.key?(:'password')
      self.password = attributes[:'password']
    end

    if attributes.key?(:'pulp_labels')
      if (value = attributes[:'pulp_labels']).is_a?(Hash)
        self.pulp_labels = value
      end
    end

    if attributes.key?(:'download_concurrency')
      self.download_concurrency = attributes[:'download_concurrency']
    end

    if attributes.key?(:'max_retries')
      self.max_retries = attributes[:'max_retries']
    end

    if attributes.key?(:'policy')
      self.policy = attributes[:'policy']
    else
      self.policy = 'immediate'
    end

    if attributes.key?(:'total_timeout')
      self.total_timeout = attributes[:'total_timeout']
    end

    if attributes.key?(:'connect_timeout')
      self.connect_timeout = attributes[:'connect_timeout']
    end

    if attributes.key?(:'sock_connect_timeout')
      self.sock_connect_timeout = attributes[:'sock_connect_timeout']
    end

    if attributes.key?(:'sock_read_timeout')
      self.sock_read_timeout = attributes[:'sock_read_timeout']
    end

    if attributes.key?(:'headers')
      if (value = attributes[:'headers']).is_a?(Array)
        self.headers = value
      end
    end

    if attributes.key?(:'rate_limit')
      self.rate_limit = attributes[:'rate_limit']
    end

    if attributes.key?(:'includes')
      if (value = attributes[:'includes']).is_a?(Array)
        self.includes = value
      end
    end

    if attributes.key?(:'excludes')
      if (value = attributes[:'excludes']).is_a?(Array)
        self.excludes = value
      end
    end

    if attributes.key?(:'prereleases')
      self.prereleases = attributes[:'prereleases']
    end

    if attributes.key?(:'package_types')
      if (value = attributes[:'package_types']).is_a?(Array)
        self.package_types = value
      end
    end

    if attributes.key?(:'keep_latest_packages')
      self.keep_latest_packages = attributes[:'keep_latest_packages']
    else
      self.keep_latest_packages = 0
    end

    if attributes.key?(:'exclude_platforms')
      if (value = attributes[:'exclude_platforms']).is_a?(Array)
        self.exclude_platforms = value
      end
    end

    # Note: provenance field is intentionally skipped for backwards compatibility
  end
end
