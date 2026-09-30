require 'json'
require 'pulp_file_client'

# Older pulp_file sync endpoints reject optimize, including explicit false.
# Keep the requested behavior on newer Pulp and retry only this validation error.
# Remove when all supported targets have pulp_file >= 3.115.0.
module PulpFileSyncOptimizeCompatibility
  def sync_with_http_info(href, data, opts = {})
    super
  rescue PulpFileClient::ApiError => e
    raise unless unsupported_optimize?(e) && !opts[:debug_body]

    params = data.to_hash
    raise unless params.key?(:optimize) || params.key?('optimize')

    # Pass a hash so the generated model cannot reintroduce its optimize default.
    super(href, params.reject { |key, _| key.to_s == 'optimize' }, opts)
  end

  private

  def unsupported_optimize?(error)
    error.code == 400 && JSON.parse(error.response_body.to_s) == {'optimize' => ['Unexpected field']}
  rescue JSON::ParserError
    false
  end
end

PulpFileClient::RepositoriesFileApi.prepend(PulpFileSyncOptimizeCompatibility)
