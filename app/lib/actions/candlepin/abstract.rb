module Actions
  module Candlepin
    class Abstract < Actions::Base
      middleware.use ::Actions::Middleware::RemoteAction
      middleware.use Actions::Middleware::PropagateCandlepinErrors
    end
  end
end
