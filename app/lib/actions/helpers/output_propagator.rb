module Actions
  module Helpers
    module OutputPropagator
      def self.included(base)
        base.middleware.use ::Actions::Middleware::PropagateOutput
      end

      def run
        #empty run method
      end
    end
  end
end
