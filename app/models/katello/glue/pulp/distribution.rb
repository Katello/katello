module Katello
  module Glue::Pulp::Distribution
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        attr_accessor :_id, :id, :description, :files, :family, :variant, :version, :url, :arch, :repoids

        def self.find(id)
          Katello::Distribution.new(Katello.pulp_server.extensions.distribution.find(id))
        end
      end
    end

    module InstanceMethods
      def initialize(attrs = {}, _options = {})
        attrs[:repoids] = attrs.delete(:repository_memberships)
        generate_instance_variables(attrs)
      end

      def generate_instance_variables(attrs)
        attrs.each_pair do |k, v|
          if self.class.method_defined?(k) && !v.nil?
            instance_variable_set("@#{k}", v)
          end
        end
      end

      def as_json(*args)
        result = super(*args)
        result['files'] = (result['files'] || []).inject([]) do |paths, file|
          paths << file['relativepath']
        end
        result
      end
    end
  end
end
