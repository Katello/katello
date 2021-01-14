module Actions
  module Middleware
    class ExecuteIfContentsChanged < Dynflow::Middleware
      def run(*args)
        pass(*args) if execute?
      end

      def finalize(*args)
        pass(*args) if execute?
      end

      private

      def execute?
        if action.input.keys.include?('contents_changed') && action.input['contents_changed'] == false
          self.action.output[:post_action_skipped] = true
          false
        elsif action.input.keys.include?('matching_content') && action.input['matching_content'] == true
          self.action.output[:post_action_skipped] = true
          false
        else
          true
        end
      end
    end
  end
end
