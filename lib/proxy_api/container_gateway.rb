module ProxyAPI
  class ContainerGateway < ::ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/container_gateway"
      super args
    end

    def repository_list(args)
      # put '/v2/repository_list/?'
      @url += "/repository_list"
      parse put(args)
    rescue => e
      raise ::ProxyAPI::ProxyException.new(url, e, N_("Unable to update the repository list"))
    end

    def user_repository_mapping(args)
      # put '/v2/user_repository_mapping/?'
      @url += "/user_repository_mapping"
      parse put(args)
    rescue => e
      raise ::ProxyAPI::ProxyException.new(url, e, N_("Unable to update the user-repository mapping"))
    end

    def users
      # get '/v2/users/?'
      @url += "/users"
      @users = parse get
    rescue => e
      raise ::ProxyAPI::ProxyException.new(url, e, N_("Unable to get users"))
    end
  end
end
