module Actions
  module Pulp
    module Consumer
      class ContentPresenter < Helpers::Presenter::Base
        def humanized_output
          if task_result_packages
            ret = []
            if task_result_packages.is_a?(String)
              ret << task_result_packages
            elsif task_result_packages.any?
              ret.concat(task_result_packages.map { |package| package[:qname] })
            end
            if humanized_errors
              ret.concat(humanized_errors)
            end
            return ret.sort.join("\n")
          else
            humanized_errors #show any errors if no packages were updated
          end
        end

        private

        def task_result
          action.external_task && action.external_task[0][:result]
        end

        def task_result_details
          task_result && task_result[:details]
        end

        def task_erratum_details
          task_result_details &&
              task_result_details[:erratum] &&
              task_result_details[:erratum][:details]
        end

        def task_rpm_details
          task_result_details &&
              task_result_details[:rpm] &&
              task_result_details[:rpm][:details]
        end

        def task_package_group_details
          task_result_details &&
              task_result_details[:package_group] &&
              task_result_details[:package_group][:details]
        end

        def task_erratum_succeeded?
          task_result_details &&
              task_result_details[:erratum] &&
              task_result_details[:erratum][:succeeded] == true
        end

        def task_rpm_succeeded?
          task_result_details &&
              task_result_details[:rpm] &&
              task_result_details[:rpm][:succeeded] == true
        end

        def task_package_group_succeeded?
          task_result_details &&
              task_result_details[:package_group] &&
              task_result_details[:package_group][:succeeded] == true
        end

        def task_errors
          task_rpm_details && task_rpm_details[:errors]
        end

        def task_result_packages
          if task_rpm_details
            if task_rpm_succeeded?
              task_rpm_details[:resolved] + task_rpm_details[:deps]
            else
              task_rpm_details[:message]
            end
          elsif task_package_group_details
            if task_package_group_succeeded?
              task_package_group_details[:resolved] + task_package_group_details[:deps]
            else
              task_package_group_details[:message]
            end
          elsif task_erratum_details
            if task_erratum_succeeded?
              task_erratum_details[:resolved] + task_erratum_details[:deps]
            else
              task_erratum_details[:message]
            end
          end
        end

        def humanized_errors
          task_errors&.map { |k, v| "#{k}: #{v}" }
        end
      end
    end
  end
end
