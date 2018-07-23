module Katello
  module Glue::Pulp::DockerManifest
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def update_from_json(json)
        update_attributes(:schema_version => json[:schema_version],
                          :digest => json[:digest],
                          :downloaded => json[:downloaded],
                          :layers_size => json[:fs_layers].pluck(:size).compact.sum
                         )
      end
    end
  end
end
