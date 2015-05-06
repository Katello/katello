module Actions
  module ElasticSearch
    class Abstract < Actions::Base
      middleware.use ::Actions::Middleware::RemoteAction
    end
  end
end
