module Actions
  module Candlepin
    module Owner
      class StartUpstreamExport < Candlepin::UpstreamAbstractAsyncTask
        input_format do
          param :organization_id
          param :upstream
        end

        def invoke_external_task
          organization = ::Organization.find(input[:organization_id])
          output[:response] = organization.redhat_provider.start_owner_upstream_export(input[:upstream])
        end

        def humanized_output
          result_data = output[:task]&.[]('resultData')
          return '' if result_data&.[]('status').blank?
          "Upstream Candlepin job status: #{result_data['status']}\n
          Message: #{result_data['statusMessage']}"
        end
      end
    end
  end
end
