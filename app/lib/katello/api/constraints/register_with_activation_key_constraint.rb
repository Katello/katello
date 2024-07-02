module Katello
  module Api
    module Constraints
      class RegisterWithActivationKeyConstraint
        def matches?(request)
          request.params[:activation_keys]
        end
      end
    end
  end
end
