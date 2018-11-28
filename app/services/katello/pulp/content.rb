module Katello
  module Pulp
    class Content
      extend Katello::Abstract::Pulp::Content
      class << self
        extend Forwardable
        def_delegator :pulp_content, :create_upload_request, :create_upload
        def_delegator :pulp_content, :delete_upload_request, :delete_upload
        def_delegator :pulp_content, :upload_bits, :upload_chunk

        private def pulp_content
          SmartProxy.pulp_master.pulp_api.resources.content
        end
      end
    end
  end
end
