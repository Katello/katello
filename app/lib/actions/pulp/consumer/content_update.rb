module Actions
  module Pulp
    module Consumer
      class ContentUpdate < AbstractContentAction
        include Helpers::Presenter
        include Actions::Pulp::ExpectOneTask

        input_format do
          param :consumer_uuid, String
          param :type, %w(rpm)
          param :args, array_of(String)
        end

        def invoke_external_task
          options = { "importkeys" => true }
          options[:all] = true if input[:args].blank?

          pulp_extensions.consumer.update_content(input[:consumer_uuid],
                                                  input[:type],
                                                  input[:args],
                                                  options)
        end

        def presenter
          Consumer::ContentPresenter.new(self)
        end
      end
    end
  end
end
