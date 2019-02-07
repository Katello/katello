module Support
  module CapsuleSupport
    def pulp_feature
      @pulp_feature ||= Feature.create(name: SmartProxy::PULP_NODE_FEATURE)
    end

    def proxy_with_pulp(proxy_resource = nil)
      proxy_resource ||= :four
      smart_proxies(proxy_resource).tap do |proxy|
        unless proxy.features.include?(pulp_feature)
          proxy.features << pulp_feature
        end
      end
    end

    def capsule_content
      # This helper is useful for tests that only need a single capsule
      @capsule_content ||= Katello::Pulp::SmartProxyRepository.new(proxy_with_pulp)
    end

    def new_capsule_content(proxy_resource)
      # This helper is useful for tests involving multiple capsules
      Katello::Pulp::SmartProxyRepository.new(proxy_with_pulp(proxy_resource))
    end
  end
end
