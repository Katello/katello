#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Orchestrate
  module Helpers
    module PulpPackagesPresenter

      def task_input
        action_details.input
      end

      # Reformats the pulp_task output to Katello task details in the following
      # format:
      #
      #     { steps: [ { name: "Refresh Repository Metadata", finished: true },
      #                { name: "Downloading Packages", finished: true },
      #                { name: "Check Package Signatures", finished: true },
      #                { name: "Running Test Transaction", finished: true },
      #                { name: "Running Transaction", finished: false }],
      #       current_action: { name: "Installig",
      #                         package: "1:emacs-common-23.1-21.el6_2.3.x86_64" }
      #       result: { success: true,
      #                 packages: [ { name: "emacs",
      #                               fullname: "1:emacs-23.1-21.el6_2.3.x86_64",
      #                               dependency: false },
      #                             { name: "m17n-db-datafiles",
      #                               fullname: "m17n-db-datafiles-1.5.5-1.1.el6.noarch",
      #                               dependency: true ] }
      def task_output
        task_output = {}
        pulp_task = action_details.output[:pulp_task]
        return task_output unless pulp_task

        if steps = task_output_steps(pulp_task)
          task_output[:steps] = steps
        end

        if current_action = task_output_current_action(pulp_task)
          task_output[:current_action] = current_action
        end

        if result = task_output_result(pulp_task)
          task_output[:result] = result
        end

        return task_output
      end

      def humanized_input
        task_input[:args].join(", ")
      end

      def humanized_output
        if task_output[:result] && (packages = task_output[:result][:packages])
          return packages.map { |package| package[:fullname] }.join("\n")
        end
      end

      protected

      def pulp_subaction
        Pulp::PackageRemove
      end

      private

      def action_details
        all_actions.find { |action| action.is_a? pulp_subaction }
      end

      def task_output_steps(pulp_task)
        if (progress = pulp_task[:progress]) && progress[:steps]
          progress[:steps].map do |step_name, finished|
            { name: step_name, finished: !!finished }
          end
        end
      end

      def task_output_current_action(pulp_task)
        if (progress = pulp_task[:progress]) &&
              (details = progress[:details]) &&
              details[:action]
          { name:    details[:action],
            package: details[:package] }
        end
      end

      def task_output_result(pulp_task)
        if pulp_task[:result] &&
              pulp_task[:result][:details] &&
              (rpm_result = pulp_task[:result][:details][:rpm])
          packages = rpm_result[:details][:resolved].map do |package|
            task_output_package(package, false)
          end
          dependent_packages = rpm_result[:details][:deps].map do |package|
            task_output_package(package, true)
          end
          { success: rpm_result[:succeeded],
            errors: rpm_result[:errors],
            packages: packages + dependent_packages }
        end
      end

      def task_output_package(package, dependency)
        { name:       package[:name],
          fullname:   package[:qname],
          dependency: dependency }
      end

    end
  end
end
