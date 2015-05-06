module Actions
  module Candlepin
    module Environment
      class Destroy < Candlepin::Abstract
        input_format do
          params :cp_id
        end

        def run
          ::Katello::Resources::Candlepin::Environment.destroy(input['cp_id'])
        end
      end
    end
  end
end
