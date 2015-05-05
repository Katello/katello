module Katello
  module Glue::Pulp::PackageGroup
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        attr_accessor :name, :package_group_id, :default_package_names, :id, :repo_id, :conditional_package_names,
                        :mandatory_package_names, :description, :optional_package_names

        def self.find(id)
          attrs = Katello.pulp_server.extensions.package_group.find_by_unit_id(id)
          Katello::PackageGroup.new(attrs) unless attrs.nil?
        end

        def self.list_by_filter_clauses(clauses)
          package_groups = Katello.pulp_server.extensions.package_group.search(Katello::PackageGroup::CONTENT_TYPE,
                                                                               :filters => clauses)
          if package_groups
            groups = package_groups.collect do |attrs|
              Katello::PackageGroup.new(attrs) if attrs
            end
            groups.compact
          else
            []
          end
        end
      end
    end

    module InstanceMethods
      def initialize(params = {}, _options = {})
        params['package_group_id'] = params['id']
        params['id'] = params.delete('_id')
        params.each_pair { |k, v| instance_variable_set("@#{k}", v) unless v.nil? }

        [:default_package_names, :conditional_package_names,
         :optional_package_names, :mandatory_package_names].each do |attr|
          values = send(attr)
          values = values.collect { |v| v.split(", ") }.flatten
          send("#{attr}=", values)
        end
      end

      def package_names
        default_package_names + conditional_package_names + optional_package_names + mandatory_package_names
      end
    end
  end
end
