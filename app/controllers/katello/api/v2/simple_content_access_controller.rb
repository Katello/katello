module Katello
  class Api::V2::SimpleContentAccessController < Api::V2::ApiController
    resource_description do
      description "Red Hat subscriptions management platform."
      api_version 'v2'
    end

    def render_sca_410_error
      render_error 'custom_error', status: :gone,
                                    locals: { message: N_('Simple Content Access is the only supported content access mode') }
    end

    def eligible
      render_sca_410_error
    end

    def status
      render_sca_410_error
    end

    def enable
      render_sca_410_error
    end

    def disable
      render_sca_410_error
    end
  end
end
