module Support
  module CapsuleSupport
    def pulp_feature
      @pulp_feature ||= Feature.create(name: SmartProxy::PULP_NODE_FEATURE)
    end

    def proxy_with_pulp
      @proxy_with_pulp ||= smart_proxies(:four).tap do |proxy|
        unless proxy.features.include?(pulp_feature)
          proxy.features << pulp_feature
        end
      end
    end

    def capsule_content
      @capsule_content ||= Katello::CapsuleContent.new(proxy_with_pulp)
    end
  end
end
