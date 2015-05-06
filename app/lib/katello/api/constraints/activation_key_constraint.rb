module Katello
  class RegisterWithActivationKeyConstraint
    def matches?(request)
      request.params[:activation_keys]
    end
  end
end
