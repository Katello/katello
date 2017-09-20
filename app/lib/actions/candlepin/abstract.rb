module Actions
  module Candlepin
    class Abstract < Actions::Base
      middleware.use ::Actions::Middleware::RemoteAction
      middleware.use ::Actions::Middleware::PropagateCandlepinErrors
      middleware.use ::Actions::Middleware::CandlepinServicesCheck
      middleware.use ::Actions::Middleware::KeepSessionId
    end
  end
end
