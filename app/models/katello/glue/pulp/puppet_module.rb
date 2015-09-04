module Katello
  module Glue::Pulp::PuppetModule
    def self.included(base)
      base.send :include, LazyAccessor
      base.send :include, InstanceMethods

      base.class_eval do
        lazy_accessor :pulp_facts, :initializer => :backend_data

        lazy_accessor :_storage_path, :tag_list, :description, :license,
                      :_ns, :project_page, :source, :dependencies,
                      :_content_type_id, :checksums, :_id, :types,
                      :initializer => :pulp_facts

        def self.find_by_ids(ids)
          pulp_puppet_modules = Katello.pulp_server.extensions.puppet_module.find_all_by_unit_ids(ids)
          pulp_puppet_modules.collect { |puppet_module| Katello::PuppetModule.new(puppet_module) }
        end

        def self.generate_unit_data(filepath)
          data = parse_metadata(filepath)

          unit_key = {}.with_indifferent_access
          unit_metadata = {}.with_indifferent_access
          unit_key[:name] = data[:name][/\A.*-(.*)\z/, 1]
          unit_key[:author] = data[:name][/\A(.*)-.*\z/, 1]
          unit_key.merge!(data.slice(:version))

          unit_metadata.merge!(data.slice(:dependences, :description, :license, :project_page, :source, :summary, :tag_list))
          unit_metadata[:tag_list] ||= []

          return unit_key, unit_metadata
        end
      end
    end

    module InstanceMethods
      def puppet_name
        File.basename(@_storage_path, ".tar.gz")
      end
    end
  end
end
