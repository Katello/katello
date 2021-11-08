require "pulpcore_client"
module Katello
  module Pulp3
    class Content
      extend Katello::Abstract::Pulp::Content
      class << self
        def create_upload(size = 0, checksum = nil, content_type = nil, repository = nil)
          content_unit_href = nil
          if checksum
            content_backend_service = SmartProxy.pulp_primary.content_service(content_type)
            if repository&.generic?
              content_list = content_backend_service.content_api(repository.repository_type, content_type).list('sha256': checksum)
            else
              content_list = content_backend_service.content_api.list("sha256": checksum)
            end
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
            uploads_api.update(content_range(offset, offset + actual_chunk_size - 1, size), upload_href, filechunk)
          ensure
            filechunk.close
            filechunk.unlink
          end
        end

        private

        def core_api_client
          PulpcoreClient::ApiClient.new(SmartProxy.pulp_primary.pulp3_configuration(PulpcoreClient::Configuration))
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
