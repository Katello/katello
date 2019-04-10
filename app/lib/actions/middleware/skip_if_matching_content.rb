module Actions
  module Middleware
    class SkipIfMatchingContent < Dynflow::Middleware
      def run(*args)
        pass(*args) if execute?
      end

      def finalize(*args)
        pass(*args) if execute?
      end

      private

      def execute?
        options = action.input[:options]
        if options && options['matching_content']
          self.action.output[:matching_content_skip] = true
          false
        else
          true
        end
      end
    end
  end
end
