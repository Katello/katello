module Katello
  module Resources
    module Candlepin
      class UpstreamJob < UpstreamCandlepinResource
        class << self
          NOT_FINISHED_STATES = %w(CREATED WAITING PENDING RUNNING).freeze unless defined? NOT_FINISHED_STATES
          API_URL = 'https://subscription.rhsm.redhat.com/subscription'.freeze

          def not_finished?(job)
            NOT_FINISHED_STATES.include?(job[:state])
          end

          def get(id, upstream)
            url = API_URL
            response = Resources::Candlepin::UpstreamConsumer.start_upstream_export("#{url}#{path(id)}", upstream['idCert']['cert'],
              upstream['idCert']['key'], nil)
            job = JSON.parse(response)
            job.with_indifferent_access
          end

          def path(id = nil)
            "/jobs/#{id}"
          end
        end
      end
    end
  end
end
