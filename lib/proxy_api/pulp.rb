module ProxyAPI
  class Pulp < ::ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/pulp/status"
      super args
    end

    def pulp_storage
      @url += "/disk_usage"
      @pulp_storage ||= parse(get)
    rescue => e
      raise ::ProxyAPI::ProxyException.new(url, e, N_("Unable to detect pulp storage"))
    end
  end
end
