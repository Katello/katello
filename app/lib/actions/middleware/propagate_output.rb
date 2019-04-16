module Actions
  module Middleware
    class PropagateOutput < Dynflow::Middleware
      def run(*args)
        if action.input.keys.include?('subaction_output') && action.input['subaction_output']
          action.input['subaction_output'].each do |key, value|
            self.action.output[key] = value
          end
        end
        pass(*args)
      end
    end
  end
end
