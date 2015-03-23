#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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
            else
              ret << humanized_no_package
            end
            if humanized_errors
              ret.concat(humanized_errors)
            end
            return ret.join("\n")
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
          end
        end

        def humanized_errors
          if task_errors
            task_errors.map { |k, v| "#{k}: #{v}" }
          end
        end

        def humanized_no_package
          case action
          when Consumer::ContentInstall
            _("No new packages installed")
          when Consumer::ContentUninstall
            _("No packages removed")
          end
        end
      end
    end
  end
end
