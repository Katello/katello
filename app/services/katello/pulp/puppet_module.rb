module Katello
  module Pulp
    class PuppetModule < PulpContentUnit
      include LazyAccessor

      CONTENT_TYPE = "puppet_module".freeze

      lazy_accessor :pulp_facts, :initializer => :backend_data

      lazy_accessor :_storage_path, :tag_list, :description, :license,
                    :_ns, :project_page, :source, :dependencies,
                    :_content_type_id, :checksums, :_id, :types,
                    :initializer => :pulp_facts
    end
  end
end
