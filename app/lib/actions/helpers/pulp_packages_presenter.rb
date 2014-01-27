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

module Actions
  module Helpers
    module PulpPackagesPresenter

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
        return {} unless details_action
        pulp_task = details_action.output[:pulp_task]
        return {} unless pulp_task
        task_output = {}

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
        args = task_input[:packages] || task_input[:groups] || []
        [args.join(", ")] + Helpers::Humanizer.new(self).input
      end

      def humanized_output
        if task_output[:result] && (packages = task_output[:result][:packages])
          ret = []
          if packages.any?
            packages.each { |package| ret <<  package[:fullname] }
          else
            ret << humanized_no_package
          end
          if errors = task_output[:result][:errors]
            ret.concat(errors)
          end
          return ret.join("\n")
        end
      end

      protected

      def pulp_subaction
        Pulp::PackageRemove
      end

      def details_action
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

      def rpm_result(pulp_task)
        if pulp_task[:result] && pulp_task[:result][:details]
          return pulp_task[:result][:details][:rpm]
        end
      end

      def rpm_result_details(pulp_task)
        rpm_result = rpm_result(pulp_task)
        if rpm_result && rpm_result[:details]
          return rpm_result[:details]
        end
      end

      def task_output_result(pulp_task)
        if rpm_result = self.rpm_result(pulp_task)
          packages = rpm_result[:details][:resolved].map do |package|
            task_output_package(package, false)
          end
          dependent_packages = rpm_result[:details][:deps].map do |package|
            task_output_package(package, true)
          end
          { success: rpm_result[:succeeded],
            errors: task_output_errors(pulp_task),
            packages: packages + dependent_packages }
        end
      end

      def task_output_package(package, dependency)
        { name:       package[:name],
          fullname:   package[:qname],
          dependency: dependency }
      end

      def task_output_errors(pulp_task)
        rpm_result_details = self.rpm_result_details(pulp_task)
        if rpm_result_details[:errors]
          rpm_result_details[:errors].map do |package, message|
            "#{package}: #{message}"
          end
        end
      end

      def humanized_no_package
        case details_action
        when Actions::Pulp::Consumer::ContentInstall
          _("No new packages installed")
        when Actions::Pulp::Consumer::ContentUninstall
          _("No packages removed")
        end
      end

    end
  end
end
