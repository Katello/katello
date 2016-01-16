module ProxyAPI
  class Pulp < ::ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/pulp"
      super args
    end

    def status
      parse(get "status")
    rescue => e
      raise ProxyAPI::ProxyException.new(url, e, N_("Unable to get status from Pulp"))
    end
  end
end
