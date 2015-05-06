module Actions
  module Pulp
    module Consumer
      class AbstractContentAction < Pulp::AbstractAsyncTask
        include Helpers::Presenter
        include Actions::Pulp::ExpectOneTask

        def external_task=(external_task_data)
          super(external_task_data)
          task_errors = find_errors(output[:pulp_tasks])
          if task_errors.any?
            fail ::Katello::Errors::PulpError, task_errors.join("\n")
          end
        end

        def find_errors(tasks)
          messages = []
          tasks.each do |pulp_task|
            if pulp_task[:result] && pulp_task[:result][:details]
              pulp_task[:result][:details].each do |_content_type, result|
                unless result[:succeeded]
                  messages << result[:details][:message]
                end
              end
            end
          end
          messages
        end

        def presenter
          Consumer::ContentPresenter.new(self)
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
