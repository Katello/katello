module Katello
  module Glue::Pulp::User
    def self.included(base)
      base.send :include, InstanceMethods
      base.send :include, LazyAccessor
      base.class_eval do
        lazy_accessor :pulp_name, :initializer => lambda { |_s| Katello.pulp_server.resources.user.retrieve(self.remote_id) }
      end
    end

    module InstanceMethods
      def initialize(attrs = nil, options = {})
        attrs = prune_pulp_only_attributes(attrs)
        super
      end

      def prune_pulp_only_attributes(attrs)
        unless attrs.nil?
          attrs = attrs.reject do |k, _v|
            !self.class.column_defaults.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
          end
        end

        return attrs
      end
    end

    private

    def perform_with_admin
      used_admin_user = false
      # During db:seed, the foreman user may not be setup correctly for pulp communication
      #  so lets used a mocked 'admin' user instead
      if Katello.pulp_server.nil? || Katello.pulp_server.config['user'].blank?
        used_admin_user = true
        old_pulp_server = Katello.pulp_server
        User.current = User.new(:remote_id => Katello.config.pulp.default_login,
                                :login => Katello.config.pulp.default_login)
      end

      to_return = yield

      Katello.pulp_server = old_pulp_server if used_admin_user
      to_return
    end
  end
end
