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

    def update_hosts(args)
      # put '/v2/update_hosts/?'
      @url += "/update_hosts"
      parse put(args)
    rescue => e
      raise ::ProxyAPI::ProxyException.new(url, e, N_("Unable to update hosts"))
    end

    def host_repository_mapping(args)
      # put '/v2/update_host_repository_mapping/?'
      @url += "/host_repository_mapping"
      parse put(args)
    rescue => e
      raise ::ProxyAPI::ProxyException.new(url, e, N_("Unable to refresh host-repository mapping"))
    end

    def update_host_repositories(args)
      # put '/v2/update_host_repositories/?'
      @url += "/update_host_repositories"
      parse put(args)
    rescue => e
      raise ::ProxyAPI::ProxyException.new(url, e, N_("Unable to update host-repository mapping"))
    end
  end
end
