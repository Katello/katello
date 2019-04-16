module Actions
  module Helpers
    # Delegate task information to presenter object
    module Presenter
      def presenter
        fail NotImplementedError
      end

      delegate :humanized_output, to: :presenter

      class Base
        include Algebrick::TypeCheck

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
        def initialize(_action, delegated_actions)
          (Type! delegated_actions, Array).all? { |a| Type! a, Presenter }
          @delegated_actions = delegated_actions
        end

        def humanized_output
          @delegated_actions.map(&:humanized_output).compact.join("\n")
        end
      end
    end
  end
end
