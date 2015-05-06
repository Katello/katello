module Actions
  module Pulp
    module Consumer
      class ContentUninstall < AbstractContentAction
        include Helpers::Presenter
        include Actions::Pulp::ExpectOneTask

        input_format do
          param :consumer_uuid, String
          param :type, %w(rpm package_group)
          param :args, array_of(String)
        end

        def invoke_external_task
          pulp_extensions.consumer.uninstall_content(input[:consumer_uuid],
                                                     input[:type],
                                                     input[:args])
        end

        def presenter
          Consumer::ContentPresenter.new(self)
        end
      end
    end
  end
end
