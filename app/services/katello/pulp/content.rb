module Katello
  module Pulp
    class Content
      extend Katello::Abstract::Pulp::Content
      class << self
        def create_upload(_size = 0)
          pulp_content.create_upload_request
        end

        def delete_upload(upload_id)
          pulp_content.delete_upload_request(upload_id)
        end

        def upload_chunk(upload_id, offset, content, _size)
          pulp_content.upload_bits(upload_id, offset, content)
        end

        private def pulp_content
          SmartProxy.pulp_master.pulp_api.resources.content
        end
      end
    end
  end
end
