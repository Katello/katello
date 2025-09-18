module Katello
  module Resources
    module Candlepin
      class UpstreamJob < UpstreamCandlepinResource
        class << self
          NOT_FINISHED_STATES = %w(CREATED WAITING PENDING RUNNING).freeze unless defined? NOT_FINISHED_STATES
          API_URL = 'https://subscription.rhsm.redhat.com/subscription'.freeze
          SUBSCRIPTION_PATH = '/subscription'.freeze

          def not_finished?(job)
            NOT_FINISHED_STATES.include?(job[:state])
          end

          def get(id, upstream)
            url = subscription_path(ENV['REDHAT_RHSM_API_URL']) || subscription_path(upstream['apiUrl']) || API_URL
            response = Resources::Candlepin::UpstreamConsumer.start_upstream_export("#{url}#{path(id)}", upstream['idCert']['cert'],
              upstream['idCert']['key'], nil)
            job = JSON.parse(response)
            job.with_indifferent_access
          end

          def path(id = nil)
            "/jobs/#{id}"
          end

          def subscription_path(upstream_api_url)
            return if upstream_api_url.blank?
            uri = URI.parse(upstream_api_url) # https://subscription.rhsm.redhat.com/subscription/consumers/
            uri.path = SUBSCRIPTION_PATH # https://subscription.rhsm.redhat.com/subscription
            uri.to_s
          end
        end
      end
    end
  end
end
