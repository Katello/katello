module Katello
  module Abstract
    module Pulp
      module Content
        def create_upload
          fail NotImplementedError
        end

        def upload_chunk
          fail NotImplementedError
        end

        def delete_upload
          fail NotImplementedError
        end
      end
    end
  end
end
