require "pulpcore_client"
module Katello
  module Pulp3
    class Content
      extend Katello::Abstract::Pulp::Content
      class << self
        def create_upload(size = 0, checksum = nil, content_type = nil)
          content_unit_href = nil
          if checksum && content_type
            content_backend_service = SmartProxy.pulp_master.content_service(content_type)
            content_list = content_backend_service.content_api.list("digest": checksum)
            content_unit_href = content_list.results.first.pulp_href unless content_list.results.empty?
            return {"content_unit_href" => content_unit_href} if content_unit_href
          end
          upload_href = uploads_api.create(upload_class.new(size: size)).pulp_href
          {"upload_id" => upload_href.split("/").last}
        end

        def delete_upload(upload_href)
          #Commit deletes upload request for pulp3. Not needed other than to implement abstract method.
        end

        def upload_chunk(upload_href, offset, content, size)
          upload_href = "/pulp/api/v3/uploads/" + upload_href + "/"
          offset = offset.try(:to_i)
          size = size.try(:to_i)
          begin
            filechunk = Tempfile.new('filechunk', :encoding => 'ascii-8bit')
            filechunk.write(content)
            filechunk.flush
            actual_chunk_size = File.size(filechunk)
            uploads_api.update(upload_href, content_range(offset, offset + actual_chunk_size - 1, size), filechunk)
          ensure
            filechunk.close
            filechunk.unlink
          end
        end

        private

        def core_api_client
          PulpcoreClient::ApiClient.new(SmartProxy.pulp_master.pulp3_configuration(PulpcoreClient::Configuration))
        end

        def uploads_api
          PulpcoreClient::UploadsApi.new(core_api_client)
        end

        def upload_class
          PulpcoreClient::Upload
        end

        def content_range(start, finish, total)
          finish = finish > total ? total : finish
          "bytes #{start}-#{finish}/#{total}"
        end
      end
    end
  end
end
