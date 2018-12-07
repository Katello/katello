module Katello
  module Resources
    module Candlepin
      class Job < CandlepinResource
        class << self
          NOT_FINISHED_STATES = %w(CREATED WAITING PENDING RUNNING).freeze unless defined? NOT_FINISHED_STATES

          def not_finished?(job)
            NOT_FINISHED_STATES.include?(job[:state])
          end

          def get(id, params = {})
            job_json = super(path(id) + hash_to_query(params), self.default_headers).body
            job = JSON.parse(job_json)
            job.with_indifferent_access
          end

          def path(id = nil)
            "/candlepin/jobs/#{id}"
          end
        end
      end
    end
  end
end
