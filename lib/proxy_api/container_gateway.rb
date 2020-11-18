module ProxyAPI
  class ContainerGateway < ::ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/container_gateway/v2"
      super args
    end

    def unauthenticated_repository_list(args = {})
      # get '/v2/unauthenticated_repository_list/?'
      # put '/v2/unauthenticated_repository_list/?'
      @url += "/unauthenticated_repository_list"
      if args.empty?
        @unauthenticated_repo_list = parse get
      else
        parse put(args)
      end
    rescue => e
      raise ::ProxyAPI::ProxyException.new(url, e, N_("Unable to perform unauthenticated repository list operation"))
    end
  end
end
