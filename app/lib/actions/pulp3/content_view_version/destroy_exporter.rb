module Actions
  module Pulp3
    module ContentViewVersion
      class DestroyExporter < Pulp3::AbstractAsyncTask
        input_format do
          param :smart_proxy_id, Integer
          param :exporter_data, Hash
          param :format, String
          param :repository_id, Integer
        end

        def invoke_external_task
          repository = ::Katello::Repository.find(input[:repository_id]) unless input[:repository_id].blank?
          ::Katello::Pulp3::ContentViewVersion::Export.create(smart_proxy: smart_proxy,
                                                              format: input[:format],
                                                              repository: repository).destroy_exporter(input[:exporter_data])
        end
      end
    end
  end
end
