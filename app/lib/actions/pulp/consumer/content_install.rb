module Actions
  module Pulp
    module Consumer
      class ContentInstall < AbstractContentAction
        include Helpers::Presenter
        include Actions::Pulp::ExpectOneTask

        input_format do
          param :consumer_uuid, String
          param :type, %w(rpm package_group erratum)
          param :args, array_of(String)
        end

        def invoke_external_task
          task = pulp_extensions.consumer.install_content(input[:consumer_uuid],
                                                   input[:type],
                                                   input[:args],
                                                    "importkeys" => true)
          schedule_timeout(Setting['content_action_accept_timeout'])
          task
        end

        def finalize
          check_error_details
        end

        def check_error_details
          output[:pulp_tasks].each do |pulp_task|
            error_details = pulp_task.try(:[], "result").try(:[], "details").try(:[], "rpm").try(:[], "details").try(:[], "trace")
            error_message = pulp_task.try(:[], "result").try(:[], "details").try(:[], "rpm").try(:[], "details").try(:[], "message")
            if error_details && error_details.include?("YumDownloadError") && error_message
              fail _("An error occurred during the sync \n%{error_message}") % {:error_message => error_details}
            end
          end
        end

        def presenter
          Consumer::ContentPresenter.new(self)
        end
      end
    end
  end
end
