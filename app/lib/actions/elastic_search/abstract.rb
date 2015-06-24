module Actions
  module ElasticSearch
    class Abstract < Actions::Base
      middleware.use ::Actions::Middleware::RemoteAction
      middleware.use Actions::Middleware::ElasticsearchServicesCheck
    end
  end
end
