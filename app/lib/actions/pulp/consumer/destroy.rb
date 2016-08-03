module Actions
  module Pulp
    module Consumer
      class Destroy < Pulp::Abstract
        input_format do
          param :uuid, String
        end

        def run
          pulp_extensions.consumer.delete(self.input[:uuid])
        rescue RestClient::ResourceNotFound
          Rails.logger.error(_("Pulp Consumer %s has already been removed") % input[:uuid])
        end
      end
    end
  end
end
