module Actions
  module Candlepin
    class UpstreamAbstractAsyncTask < AbstractAsyncTask
      input_format do
        param :upstream
      end

      def done?
        check_for_errors!(external_task)
        !::Katello::Resources::Candlepin::UpstreamJob.not_finished?(external_task)
      end

      def candlepin
        "Upstream Candlepin"
      end

      private

      def poll_external_task
        ::Katello::Resources::Candlepin::UpstreamJob.get(external_task[:id], input[:upstream])
      end

      def check_for_errors!(task)
        if task[:state] == 'FAILED'
          fail ::Katello::Errors::CandlepinError, task[:resultData]
        end
      end
    end
  end
end
