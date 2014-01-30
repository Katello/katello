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
    # Delegate task information to presenter object
    module Presenter

      def presenter
        fail NotImplementedError
      end

      def humanized_output
        presenter.humanized_output
      end

      class Base

        attr_reader :action

        def initialize(action)
          @action = action
        end

        def humanized_output
          fail NotImplementedError
        end
      end

      # Use sub-actions for presenting the data of the task
      class Delegated < Base

        def initialize(action, *delegated_action_classes)
          @delegated_actions = action.all_actions.find_all do |subaction|
            delegated_action_classes.any? do |action_class|
              subaction.is_a? action_class
            end
          end
        end

        def humanized_output
          @delegated_actions.map(&:humanized_output).join("\n")
        end

      end
    end
  end
end
