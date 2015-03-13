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

        def presenter
          Consumer::ContentPresenter.new(self)
        end
      end
    end
  end
end
