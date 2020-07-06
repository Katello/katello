module Support
  module CapsuleSupport
    def pulp_features
      @pulp_node_feature ||= Feature.create(name: SmartProxy::PULP_NODE_FEATURE)
      @pulp3_feature ||= Feature.create(name: SmartProxy::PULP3_FEATURE)
      [@pulp_node_feature, @pulp3_feature]
    end

    def proxy_with_pulp(proxy_resource = nil)
      proxy_resource ||= :four
      smart_proxies(proxy_resource).tap do |proxy|
        pulp_features.each do |pulp_feature|
          unless proxy.features.include?(pulp_feature)
            proxy.features << pulp_feature
          end
        end
        proxy.smart_proxy_features.where(:feature_id => @pulp3_feature.id).update(:capabilities => [:pulpcore])
      end
    end

    def with_pulp3_features(smart_proxy)
      spf = smart_proxy.smart_proxy_features.find_by(:feature_id => Feature.find_by(:name => SmartProxy::PULP3_FEATURE))
      spf.capabilities = ['pulp_file', 'pulp_container', 'pulp_ansible']
      spf.save!
    end

    def with_pulp3_yum_features(smart_proxy)
      spf = smart_proxy.smart_proxy_features.find_by(:feature_id => Feature.find_by(:name => SmartProxy::PULP3_FEATURE))
      spf.capabilities = ['pulp_file', 'pulp_container', 'pulp_ansible', 'pulp_rpm']
      spf.save!
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
