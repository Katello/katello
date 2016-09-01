module ProxyAPI
  class PulpNode < ::ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/pulpnode/status"
      super args
    end

    def pulp_storage
      @url += "/disk_usage"
      @pulp_storage ||= parse(get)
    rescue => e
      raise ::ProxyAPI::ProxyException.new(url, e, N_("Unable to detect pulp storage"))
    end

    def capsule_puppet_path
      @url += "/puppet"
      @capsule_puppet_path ||= parse(get)
    rescue => e
      raise ::ProxyAPI::ProxyException.new(url, e, N_("Unable to detect puppet path"))
    end
  end
end
