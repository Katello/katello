module Actions
  module Pulp3
    module ContentViewVersion
      class CreateImport < Pulp3::AbstractAsyncTask
        input_format do
          param :organization_id, Integer
          param :smart_proxy_id, Integer
          param :importer_data, Hash
          param :path, String
          param :metadata, Hash
        end

        def invoke_external_task
          metadata_map = ::Katello::Pulp3::ContentViewVersion::MetadataMap.new(metadata: input[:metadata])
          output[:pulp_tasks] = ::Katello::Pulp3::ContentViewVersion::Import.new(
            organization: ::Organization.find(input[:organization_id]),
            smart_proxy: smart_proxy,
            path: input[:path],
            metadata_map: metadata_map
          ).create_import(input[:importer_data][:pulp_href])
        end

        def rescue_strategy_for_self
          # There are various reasons the importing fails, not all of them are
          # fatal: when fail on import, we continue with the task ending up
          # in the warning state, but not locking further imports
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
